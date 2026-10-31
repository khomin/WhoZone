#ifndef DETECTOR_H
#define DETECTOR_H

#include <atomic>
#include <functional>
#include <mutex>
#include <string>
#include <thread>
#include <vector>
#include "net.h"
#include "detection_item.h"
#include "frame_item.h"
#include "safe_queue.h"
#include "tracker.h"

class Detector {
public:
    Detector(std::vector<std::string> class_names, std::string model_path,
             int target_width, int target_height);
    ~Detector();

    int start();

    void onDetection(std::function<void(Detection& detection)> v);
    void onFrameSaved(std::function<void(std::string path)> v);

    // True when the next camera frame would actually be used. Converting a frame
    // is not free, so the caller checks this first and drops the frame otherwise.
    bool wantsFrame();
    void pushFrame(FrameItem& frame);
    void saveOneFrameTo(std::string path);
    // Forget all tracks, the camera is about to change
    void reset();
private:
    bool loadModel();
    void process(FrameItem& frame);
    std::vector<Measurement> infer(const cv::Mat& frame);
    void send_result(const std::vector<TrackedBox>& boxes, cv::Mat& frame);
    void saveFrameIfRequested(const std::vector<TrackedBox>& boxes, cv::Mat& frame);

    std::function<void(Detection& detection)> _onDetection;
    std::function<void(std::string path)> _onFrameSaved;
    std::thread _thread;
    std::atomic<bool> _running{false};
    std::atomic<bool> _ready{false};
    std::atomic<bool> _busy{false};
    std::atomic<bool> _reset_requested{false};
    std::atomic<int64_t> _last_frame_ns{0};
    std::atomic<int64_t> _inference_interval_ns{0};
    SafeQueue<FrameItem> _frame_queue{1}; // newest frame wins, never a backlog

    std::vector<std::string> _class_names;
    ncnn::Net _net;
    std::string _model_path;
    BoxTracker _tracker;
    bool _had_boxes = false;
    int _frame_count = 0;
    std::mutex _save_mutex;
    std::string _save_one_frame_to;
    int _model_width = 0;
    int _model_height = 0;
};

#endif // DETECTOR_H
