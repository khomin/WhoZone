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

AImageReader* _reader = nullptr;
Detector* _detector = nullptr;
std::mutex _mutex;
long _frame_count = 0;
app::InitParam _initial_params;
app::CameraInfo _camera;

extern "C"
JNIEXPORT void JNICALL
Java_com_who_zone_WhoZoneRep_init(JNIEnv *env, jobject thiz, jbyteArray data, jint len) {
    std::lock_guard<std::mutex> lk(_mutex);
    jbyte *data_byte = env->GetByteArrayElements(data, nullptr);
    _initial_params.ParseFromArray(data_byte, len);
    std::vector<std::string> names(
            _initial_params.coco_names().begin(),
            _initial_params.coco_names().end()
    );
    _detector = new Detector(
            std::vector<std::string>(_initial_params.coco_names().begin(), _initial_params.coco_names().end()),
            _initial_params.model_path(),
            _initial_params.model_frame_width(),
            _initial_params.model_frame_height()
    );
    _detector->start();
    _detector->onDetection([&] (Detection & detection) {
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
    _detector->onFrameSaved([&] (std::string path) {
        app::EventWrapper event;
        auto frameSaved = new app::FrameSaved();
        frameSaved->set_path(path);
        event.set_allocated_frame_saved(frameSaved);
        sendToDart(&event);
    });
    env->ReleaseByteArrayElements(data, data_byte, 0);
}

void onFrame(void* context, AImageReader* reader) {
    AImage* image = nullptr;
    if (AImageReader_acquireNextImage(reader, &image) == AMEDIA_OK) {
        int32_t uvPixelStride = 0;
        uint8_t* yData = nullptr, * uData = nullptr, * vData = nullptr;
        int32_t yStride = 0, uStride = 0, vStride = 0;
        int32_t yLen = 0, uLen = 0, vLen = 0;
        int width = _initial_params.image_reader_width();
        int height = _initial_params.image_reader_height();
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
        if (_camera.sensor_rotation() != 0) {
            if (_camera.sensor_rotation() == 90)
                cv::rotate(frame, frame, cv::ROTATE_90_CLOCKWISE);
            else if (_camera.sensor_rotation() == 180)
                cv::rotate(frame, frame, cv::ROTATE_180);
            else if (_camera.sensor_rotation() == 270)
                cv::rotate(frame, frame, cv::ROTATE_90_COUNTERCLOCKWISE);
        }
        if(_camera.is_front()) {
            cv::flip(frame, frame, 1);
        }
        AImage_delete(image);

        auto frame_item = FrameItem{
            .frame = frame,
            .timestamp = _frame_count,
            .frame_index = static_cast<int>(_frame_count),
        };
        _detector->pushFrame(frame_item);
    }
}

extern "C"
JNIEXPORT jobject JNICALL
Java_com_who_zone_WhoZoneRep_nativeInitImageReader(JNIEnv *env, jobject thiz) {
    ANativeWindow* nativeWindow = nullptr;
    AImageReader_new(_initial_params.image_reader_width(), _initial_params.image_reader_height(), AIMAGE_FORMAT_YUV_420_888, 3, &_reader);
    AImageReader_ImageListener listener {
        .onImageAvailable = onFrame
    };
    AImageReader_setImageListener(_reader, &listener);
    AImageReader_getWindow(_reader, &nativeWindow);
    return ANativeWindow_toSurface(env, nativeWindow);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_who_zone_WhoZoneRep_setCameraMeta(JNIEnv *env, jobject thiz, jbyteArray data, jint len) {
    std::lock_guard<std::mutex> lk(_mutex);
    app::CameraInfo camera;
    jbyte *data_byte = env->GetByteArrayElements(data, nullptr);
    camera.ParseFromArray(data_byte, len);
    _camera = camera;
    env->ReleaseByteArrayElements(data, data_byte, 0);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_who_zone_WhoZoneRep_nativeSaveOneFrame(JNIEnv *env, jobject thiz, jstring path) {
    auto nativePath = env->GetStringUTFChars(path, nullptr);
    _detector->saveOneFrameTo(nativePath);
    env->ReleaseStringUTFChars(path, nativePath);
}