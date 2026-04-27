#include <vector>
#include <condition_variable>
#include <csignal>
#include "detector.h"
#include "protobuf/generated/app.pb.h"
#include <jni.h>

Detector* detector = nullptr;
std::mutex mtx;

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

// detector.onFrame = [&](DetectionWorkItem& item) {
//     // signal_client.queueUpdate(item);
// };
// detector.run();

extern "C"
JNIEXPORT void JNICALL
Java_com_who_zone_WhoZoneRep_init(JNIEnv *env, jobject thiz, jbyteArray byte_array, jint len) {
    std::lock_guard<std::mutex> lk(mtx);

    jbyte *data_byte = env->GetByteArrayElements(byte_array, nullptr);
    app::InitParam params;
    params.ParseFromArray(data_byte, len);
    std::vector<std::string> names(
            params.coco_names().begin(),
            params.coco_names().end()
    );
    detector = new Detector(
std::vector<std::string>(params.coco_names().begin(),params.coco_names().end()),
params.model_path()
    );
    env->ReleaseByteArrayElements(byte_array, data_byte, 0);
}
extern "C"
JNIEXPORT void JNICALL
Java_com_who_zone_WhoZoneRep_nativeInitImageReader(JNIEnv *env, jobject thiz, jobject reader) {
    // TODO: implement nativeInitImageReader()
}
extern "C"
JNIEXPORT void JNICALL
Java_com_who_zone_WhoZoneRep_nativeSetOutputWindow(JNIEnv *env, jobject thiz, jobject surface) {
    // TODO: implement nativeSetOutputWindow()
}