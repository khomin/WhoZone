#include <vector>
#include <condition_variable>
#include <csignal>
#include <media/NdkImageReader.h>
#include <android/native_window_jni.h>
#include <jni.h>
#include "detector.h"
#include "dart_lib.h"
#include "log.h"
#include "libyuv/version.h"
#include "libyuv/convert.h"
#include "libyuv/basic_types.h"
#include "libyuv/convert.h"
#include "libyuv/convert_argb.h"
#include "libyuv/convert_from.h"
#include "libyuv/convert_from_argb.h"
#include "libyuv/rotate.h"
#include "protobuf/generated/app.pb.h"

AImageReader* g_reader = nullptr;
Detector* detector = nullptr;
std::mutex mtx;
long frame_index = 0;
int camera_sensor_rotation = 0;
app::InitParam initial_params;

extern "C"
JNIEXPORT void JNICALL
Java_com_who_zone_WhoZoneRep_init(JNIEnv *env, jobject thiz, jbyteArray byte_array, jint len) {
    std::lock_guard<std::mutex> lk(mtx);

    jbyte *data_byte = env->GetByteArrayElements(byte_array, nullptr);

    initial_params.ParseFromArray(data_byte, len);
    std::vector<std::string> names(
            initial_params.coco_names().begin(),
            initial_params.coco_names().end()
    );
    detector = new Detector(
        std::vector<std::string>(initial_params.coco_names().begin(), initial_params.coco_names().end()),
        initial_params.model_path(),
        initial_params.model_frame_width(),
        initial_params.model_frame_height()
    );
    detector->start();
    detector->setCallback([&] (Detection & detection) {
        auto now = std::chrono::steady_clock::now();
        auto now_ns  = std::chrono::duration_cast<std::chrono::nanoseconds>(now.time_since_epoch()).count();
        auto prev = detector->getPreviousDetection();
        if(prev.has_value()) {
            LOGD("DETECTION: time lapsed: %d", now_ns - prev->timestamp_ns);
        }
        auto appDetection = new app::Detection();
        auto item = new app::DetectionItem();
        appDetection->set_frame_count(detection.frame_count);
        appDetection->set_timestamp_ns(detection.timestamp_ns);
        for(auto it: detection.detections) {
            auto p = appDetection->add_item();
            p->mutable_detection()->set_x(it.x);
            p->mutable_detection()->set_y(it.y);
            p->mutable_detection()->set_width(it.width);
            p->mutable_detection()->set_height(it.height);
            p->set_class_id(it.class_id);
            p->set_confidence(it.confidence);
        }
        app::EventWrapper event;
        event.set_allocated_detection(appDetection);
        sendToDart(&event);
    });

    env->ReleaseByteArrayElements(byte_array, data_byte, 0);
}

void onFrame(void* context, AImageReader* reader) {
    AImage* image = nullptr;
    if (AImageReader_acquireNextImage(reader, &image) == AMEDIA_OK) {
        int32_t uvPixelStride = 0;
        uint8_t* yData = nullptr, * uData = nullptr, * vData = nullptr;
        int32_t yStride = 0, uStride = 0, vStride = 0;
        int32_t yLen = 0, uLen = 0, vLen = 0;
        int width = initial_params.image_reader_width();
        int height = initial_params.image_reader_height();
        // Get Y plane (always exists)
        if (AImage_getPlaneData(image, 0, &yData, &yLen) != AMEDIA_OK) {
            AImage_delete(image);
            return;
        }
        AImage_getPlaneRowStride(image, 0, &yStride);
        AImage_getPlanePixelStride(image, 1, &uvPixelStride);
        AImage_getPlaneData(image, 1, &uData, &uLen);
        AImage_getPlaneRowStride(image, 1, &uStride);
        AImage_getPlaneData(image, 2, &vData, &vLen);
        AImage_getPlaneRowStride(image, 2, &vStride);

        // OpenCV uses BGR by default, not RGB!
        // If you use imwrite, you want BGR.
        cv::Mat frame(height, width, CV_8UC3);

        if (uvPixelStride == 2) {
            // INTERLEAVED FORMAT (NV12 or NV21)
            if (vData < uData) {
                // V-U interleaved
                libyuv::NV21ToRGB24(yData, yStride, vData, vStride, frame.data, width * 3, width, height);
            } else {
                // U-V interleaved
                libyuv::NV12ToRGB24(yData, yStride, uData, uStride, frame.data, width * 3, width, height);
            }
        } else {
            // True Planar (Rare on modern Android, but keep as fallback)
            libyuv::I420ToRGB24(
                    yData, yStride,
                    uData, uStride,
                    vData, vStride,
                    frame.data, width * 3,
                    width, height
            );
        }

        if (camera_sensor_rotation != 0) {
            if (camera_sensor_rotation == 90)
                cv::rotate(frame, frame, cv::ROTATE_90_CLOCKWISE);
            else if (camera_sensor_rotation == 180)
                cv::rotate(frame, frame, cv::ROTATE_180);
            else if (camera_sensor_rotation == 270)
                cv::rotate(frame, frame, cv::ROTATE_90_COUNTERCLOCKWISE);
        }
        AImage_delete(image);

        auto frame_item = FrameItem{
            .frame = frame,
            .timestamp = frame_index,
            .frame_index = static_cast<int>(frame_index),
        };
        detector->pushFrame(frame_item);
    }
}

extern "C"
JNIEXPORT jobject JNICALL
Java_com_who_zone_WhoZoneRep_nativeInitImageReader(JNIEnv *env, jobject thiz) {
    ANativeWindow* nativeWindow = nullptr;
    AImageReader_new(initial_params.image_reader_width(), initial_params.image_reader_height(), AIMAGE_FORMAT_YUV_420_888, 3, &g_reader);
    AImageReader_ImageListener listener {
        .onImageAvailable = onFrame
    };
    AImageReader_setImageListener(g_reader, &listener);
    AImageReader_getWindow(g_reader, &nativeWindow);
    return ANativeWindow_toSurface(env, nativeWindow);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_who_zone_WhoZoneRep_setCameraSensorRotation(JNIEnv *env, jobject thiz, jint rotation) {
    std::lock_guard<std::mutex> lk(mtx);
    camera_sensor_rotation = rotation;
}

extern "C"
JNIEXPORT void JNICALL
Java_com_who_zone_WhoZoneRep_nativeSaveOneFrame(JNIEnv *env, jobject thiz, jstring path) {
    auto nativePath = env->GetStringUTFChars(path, nullptr);
    detector->saveOneFrameTo(nativePath);
    env->ReleaseStringUTFChars(path, nativePath);
}