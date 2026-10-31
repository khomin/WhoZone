
#include <algorithm>
#include <chrono>
#include <iostream>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>
#include <pthread.h>
#include "cpu.h"
#include "detector.h"

// --- Configuration Constants ---
const float CONF_THRESHOLD = 0.30; // Minimum confidence to keep a box
const float NMS_THRESHOLD = 0.50;  // IoU threshold for Non-Maximum Suppression
const int CLASS_SCORES_OFFSET = 4; // [cx, cy, w, h, score_0 .. score_79]

// Fast enough for the tracker to follow anything. Phones throttle hard in a few
// minutes of camera + inference, so the limit here is heat, not peak speed.
const int64_t TRACKING_INTERVAL_NS = 66'000'000;
// An empty scene needs far less: a new object still appears within 200ms, and
// the big cores stay idle most of the time, so long sessions don't overheat.
const int64_t IDLE_INTERVAL_NS = 125'000'000;

namespace {

int64_t now_ns() {
    auto now = std::chrono::steady_clock::now();
    return std::chrono::duration_cast<std::chrono::nanoseconds>(now.time_since_epoch()).count();
}

float iou(const Measurement& a, const Measurement& b) {
    float w = std::min(a.x + a.width, b.x + b.width) - std::max(a.x, b.x);
    float h = std::min(a.y + a.height, b.y + b.height) - std::max(a.y, b.y);
    if (w <= 0 || h <= 0) return 0;
    float inter = w * h;
    return inter / (a.width * a.height + b.width * b.height - inter);
}

std::vector<Measurement> nms(std::vector<Measurement>& boxes) {
    std::sort(boxes.begin(), boxes.end(), [](const Measurement& a, const Measurement& b) {
        return a.confidence > b.confidence;
    });
    std::vector<Measurement> kept;
    for (auto& box : boxes) {
        bool overlaps = std::any_of(kept.begin(), kept.end(), [&](const Measurement& k) {
            return iou(box, k) > NMS_THRESHOLD;
        });
        if (!overlaps) kept.push_back(box);
    }
    return kept;
}

} // namespace

Detector::Detector(std::vector<std::string> class_names,
                   std::string model_path,
                   int model_width, int model_height
) :
    _class_names(class_names),
    _model_path(model_path),
    _model_width(model_width),
    _model_height(model_height)
{
}

Detector::~Detector() {
    _running = false;
    _frame_queue.request_shutdown();
    if (_thread.joinable()) {
        _thread.join();
    }
}

int Detector::start() {
    if (_class_names.empty()) {
        std::cerr << "ERROR: class names should not be empty!" << std::endl;
        return -1;
    }
    if (_thread.joinable()) {
        return 0;
    }
    _running = true;
    // The model is loaded here to keep it off the app's main thread
    _thread = std::thread([this] {
        pthread_setname_np(pthread_self(), "Detector");
        if (!loadModel()) {
            return;
        }
        _ready = true;
        while (_running) {
            std::optional<FrameItem> frame_item = _frame_queue.pop();
            if (frame_item.has_value()) {
                process(frame_item.value());
            }
            _busy = false;
        }
        std::cerr << "INFO: Exiting loop." << std::endl;
    });
    return 0;
}

bool Detector::loadModel() {
    // Big cores only: on the little ones inference is several times slower.
    // Two threads give 3/4 of the speed of four for 2/3 of the energy, and leave
    // big cores free for the camera and the UI.
    ncnn::set_cpu_powersave(2);
    int threads = std::max(1, std::min(2, ncnn::get_big_cpu_count()));
    ncnn::set_omp_num_threads(threads);
    _net.opt.num_threads = threads;
    _net.opt.openmp_blocktime = 0; // don't spin between frames
    _net.opt.use_vulkan_compute = false;
    // fp16 is twice as fast but moves scores by up to 0.19 and loses
    // low-confidence objects. fp32 gives the exact same output as the ONNX model.
    _net.opt.use_fp16_arithmetic = false;
    _net.opt.use_fp16_storage = false;
    _net.opt.use_fp16_packed = false;

    auto bin_path = _model_path.substr(0, _model_path.rfind('.')) + ".bin";
    if (_net.load_param(_model_path.c_str()) != 0 || _net.load_model(bin_path.c_str()) != 0) {
        std::cerr << "ERROR: Failed to load model!" << std::endl;
        return false;
    }
    return true;
}

void Detector::onDetection(std::function<void(Detection& detection)> v) {
    _onDetection = v;
}

void Detector::onFrameSaved(std::function<void(std::string)> v) {
    _onFrameSaved = v;
}

bool Detector::wantsFrame() {
    if (!_ready || _busy) {
        return false;
    }
    return now_ns() - _last_frame_ns >= _inference_interval_ns;
}

void Detector::pushFrame(FrameItem& frame) {
    _busy = true;
    _last_frame_ns = frame.timestamp;
    _frame_queue.push(std::move(frame));
}

void Detector::saveOneFrameTo(std::string path) {
    std::lock_guard<std::mutex> lock(_save_mutex);
    _save_one_frame_to = path;
}

void Detector::reset() {
    _reset_requested = true;
}

void Detector::process(FrameItem& frameItem) {
    if (_reset_requested.exchange(false)) {
        _tracker.reset();
    }
    try {
        // the frame time is used, not "now": the box must match the picture it came from
        _tracker.update(infer(frameItem.frame), frameItem.timestamp);
        _inference_interval_ns = _tracker.empty() ? IDLE_INTERVAL_NS : TRACKING_INTERVAL_NS;
        auto boxes = _tracker.visible();
        send_result(boxes, frameItem.frame);
        saveFrameIfRequested(boxes, frameItem.frame);
    } catch (const cv::Exception& e) {
        std::cerr << "OpenCV process exception: " << e.what() << std::endl;
    }
}

std::vector<Measurement> Detector::infer(const cv::Mat& frame) {
    // --- Pre-processing (Image to Blob) ---
    ncnn::Mat input = ncnn::Mat::from_pixels_resize(frame.data, ncnn::Mat::PIXEL_BGR2RGB,
                                                    frame.cols, frame.rows, frame.step,
                                                    _model_width, _model_height);
    const float norm[3] = {1 / 255.0f, 1 / 255.0f, 1 / 255.0f};
    input.substract_mean_normalize(nullptr, norm);

    // --- Inference (Forward Pass) ---
    ncnn::Extractor extractor = _net.create_extractor();
    extractor.input("in0", input);
    ncnn::Mat output; // h = 84 rows, w = one column per anchor
    if (extractor.extract("out0", output) != 0 || output.empty()) {
        return {};
    }

    // In YOLO11, there is no separate "Objectness" score.
    // You find the max class score directly.
    float x_factor = frame.cols / static_cast<float>(_model_width);
    float y_factor = frame.rows / static_cast<float>(_model_height);
    int class_count = output.h - CLASS_SCORES_OFFSET;

    // 2100 anchors x 80 classes on every frame, this has to stay cheap
    std::vector<const float*> scores(class_count);
    for (int c = 0; c < class_count; c++) {
        scores[c] = output.row(c + CLASS_SCORES_OFFSET);
    }
    const float* cx_row = output.row(0);
    const float* cy_row = output.row(1);
    const float* w_row = output.row(2);
    const float* h_row = output.row(3);

    std::vector<Measurement> boxes;
    for (int i = 0; i < output.w; i++) {
        float max_score = 0;
        int class_id = 0;
        for (int c = 0; c < class_count; c++) {
            float score = scores[c][i];
            if (score > max_score) {
                max_score = score;
                class_id = c;
            }
        }
        if (max_score > CONF_THRESHOLD) {
            float cx = cx_row[i];
            float cy = cy_row[i];
            float ow = w_row[i];
            float oh = h_row[i];
            boxes.push_back({
                (cx - 0.5f * ow) * x_factor,
                (cy - 0.5f * oh) * y_factor,
                ow * x_factor,
                oh * y_factor,
                class_id,
                max_score,
            });
        }
    }
    return nms(boxes);
}

void Detector::send_result(const std::vector<TrackedBox>& boxes, cv::Mat& frame) {
    // An empty result is only worth sending once, to clear the screen
    if (boxes.empty() && !_had_boxes) {
        return;
    }
    _had_boxes = !boxes.empty();

    float cols = static_cast<float>(frame.cols);
    float rows = static_cast<float>(frame.rows);
    Detection detection;
    detection.frame_count = ++_frame_count;
    detection.timestamp_ns = now_ns();
    detection.detections.reserve(boxes.size());
    for (auto& box : boxes) {
        DetectionItem item;
        item.x = box.x / cols;
        item.y = box.y / rows;
        item.width = box.width / cols;
        item.height = box.height / rows;
        item.velocity_x = box.vx / cols;
        item.velocity_y = box.vy / rows;
        item.track_id = box.id;
        item.class_id = box.class_id;
        item.confidence = box.confidence;
        detection.detections.push_back(item);
    }
    if (_onDetection) {
        _onDetection(detection);
    }
}

void Detector::saveFrameIfRequested(const std::vector<TrackedBox>& boxes, cv::Mat& frame) {
    std::string path;
    {
        std::lock_guard<std::mutex> lock(_save_mutex);
        path.swap(_save_one_frame_to);
    }
    if (path.empty()) {
        return;
    }
    const cv::Scalar accent(120, 255, 50); // BGR of the overlay color in the app
    const cv::Scalar text(20, 20, 20);
    cv::Rect bounds(0, 0, frame.cols, frame.rows);
    for (auto& box : boxes) {
        cv::Rect rect = cv::Rect(box.x, box.y, box.width, box.height) & bounds;
        if (rect.empty()) {
            continue;
        }
        cv::rectangle(frame, rect, accent, 2, cv::LINE_AA);

        std::string label = _class_names[box.class_id] + " " + cv::format("%d%%", static_cast<int>(box.confidence * 100));
        int baseline = 0;
        cv::Size size = cv::getTextSize(label, cv::FONT_HERSHEY_SIMPLEX, 0.45, 1, &baseline);
        int top = rect.y >= size.height + 10 ? rect.y - size.height - 10 : rect.y;
        cv::rectangle(frame, cv::Rect(rect.x, top, size.width + 10, size.height + 10), accent, cv::FILLED);
        cv::putText(frame, label, cv::Point(rect.x + 5, top + size.height + 4),
                    cv::FONT_HERSHEY_SIMPLEX, 0.45, text, 1, cv::LINE_AA);
    }
    cv::imwrite(path, frame);
    if (_onFrameSaved != nullptr) {
        _onFrameSaved(path);
    }
}
