#include <vector>
#include <condition_variable>
#include <csignal>
#include <media/NdkImageReader.h>
#include <android/native_window_jni.h>
#include <jni.h>
#include "detector.h"
#include "dart_lib.h"
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
        initial_params.model_path()
    );
    detector->start();
    detector->setCallback([&] (const auto& detection) {
        auto item = new app::DetectionItem();
        item->set_frame_count(detection.frame_count);
        item->set_timestamp_ns(detection.timestamp_ns);
        // rect
        for(auto& rect : detection.detections) {
            auto* p = item->add_detections();
            p->set_x(rect.x);
            p->set_y(rect.y);
            p->set_width(rect.width);
            p->set_height(rect.height);
        }
        // ids
        for(auto& class_id : detection.class_ids) {
            item->add_class_ids(class_id);
        }
        // confidences
        for(auto& confidence : detection.confidences) {
            item->add_confidences(confidence);
        }
        app::EventWrapper event;
        event.set_allocated_detection(item);
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
        int width = initial_params.target_width();
        int height = initial_params.target_height();
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
//        cv::cvtColor(frame, frame, cv::COLOR_RGB2BGR);
//        auto res = cv::imwrite("/storage/emulated/0/Download/who-zone-temp/1.jpeg", frame);
        AImage_delete(image);

        auto frame_item = FrameItem{
            .frame = frame,
            .timestamp = frame_index,
            .frame_index = static_cast<int>(frame_index),
        };
        detector->pushFrame(frame_item);
    }
}

// FrameItem frame;
// AImageReader_new
// frame.frame = cv::Mat(...);
// frame.frame_index = frame_index++;

extern "C"
JNIEXPORT jobject JNICALL
Java_com_who_zone_WhoZoneRep_nativeInitImageReader(JNIEnv *env, jobject thiz) {
    ANativeWindow* nativeWindow = nullptr;
    AImageReader_new(initial_params.target_width(), initial_params.target_height(), AIMAGE_FORMAT_YUV_420_888, 3, &g_reader);
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
Java_com_who_zone_WhoZoneRep_nativeSetOutputWindow(JNIEnv *env, jobject thiz, jobject surface) {
    // TODO: implement nativeSetOutputWindow()
}

//std::atomic<bool> ready_to_exit = false;
//std::condition_variable condition;
//
//void signalHandler(int signal) {
//    std::lock_guard<std::mutex> lock(mtx);
//    ready_to_exit = true;
//    condition.notify_all();
//}

//int main() {
//    std::signal(SIGINT, signalHandler);
//
//    config::Config config;
//
////    // processes frames
////    Detector detector(
////        load_coco_names(config.get<std::string>("CocoNames")),
////        config.get<std::string>("YOLO.model_path")
////    );
//
//    detector.setTexture();
//
//    // reads frames (camera, file)
//    FrameSourceOpenCV source = FrameSourceOpenCV(config.get<int>("camera_id"));
//    source.onFrame = [&](FrameItem& frame) {
//        if (ready_to_exit) return;
//        detector.pushFrame(frame);
//        // signal_client.queueUpdate(item);
//    };
//
//    if (!source.open()) {
//        std::cerr << "Failed to open camera source!" << std::endl;
//        return 1;
//    }
//    detector.start();
//
//    std::cout << "Engine running. Press Ctrl+C to stop." << std::endl;
//
//    std::unique_lock<std::mutex> lock(mtx);
//    condition.wait(lock, []{ return ready_to_exit.load() ; });
//
//    std::cout << "Shutdown complete." << std::endl;

//    return 0;
//}

// AsyncNetworkClient signal_client(
//     config.get<std::string>("Networking.signal_ip") + ":" + std::to_string(config.get<int>("Networking.signal_port"))
// );

// detector.onFrame = [&](DetectionItem& item) {
//     // signal_client.queueUpdate(item);
// };
// detector.run();