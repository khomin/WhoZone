
#include <fstream>
#include <sstream>
#include <iostream>
#include <vector>
#include <algorithm>
#include <limits>
#include <opencv2/dnn.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>
#include "detector.h"
#include "log.h"

// --- Configuration Constants ---
const float CONF_THRESHOLD = 0.50; // Minimum confidence to keep a box
const float NMS_THRESHOLD = 0.50;  // IoU threshold for Non-Maximum Suppression
const int MAX_MISSED_FRAMES = 70;

// --- Tracking Constants ---
const float MATCH_IoU_THRESHOLD = 0.3f;
const int MAX_MISSED = 10; // remove tracker after this many skipped frames

Detector::Detector(std::vector<std::string> class_names,
                   std::string module_path,
                   int target_width, int target_height
) :
    _class_names(class_names),
    _module_path(module_path),
    _target_width(target_width),
    _target_height(target_height)
{
    _colors.push_back(cv::Scalar(0, 255, 0));
    _colors.push_back(cv::Scalar(0, 255, 255));
    _colors.push_back(cv::Scalar(255, 255, 0));
    _colors.push_back(cv::Scalar(255, 0, 0));
    _colors.push_back(cv::Scalar(0, 0, 255));
}

Detector::~Detector() {
    _in_frame_queue.request_shutdown();
    _ai_frame_queue.request_shutdown();
}

int Detector::start() {
    if (_class_names.empty()) {
        std::cerr << "ERROR: class names should not be empty!" << std::endl;
        return -1;
    }
    _net = cv::dnn::readNetFromONNX(_module_path);
    if (_net.empty()) {
        std::cerr << "ERROR: Failed to load ONNX model!" << std::endl;
        return -1;
    }
    _net.setPreferableBackend(cv::dnn::DNN_BACKEND_OPENCV);
    _net.setPreferableTarget(cv::dnn::DNN_TARGET_CPU);

    if(_thread.joinable()) {
        _thread.join();
    }
    _running = true;
    _thread = std::thread([&] {
        while (_running) {
            std::optional<FrameItem> frame_item = _in_frame_queue.pop();
            if(frame_item.has_value()) {
                updatePrediction(frame_item.value());
                _ai_frame_queue.push(frame_item.value());
                _frame_count++;
            }
        }
        std::cerr << "INFO: Exiting loop-1." << std::endl;
    });
    _ai_thread = std::thread([&] {
        while (_running) {
            std::optional<FrameItem> frame_item = _ai_frame_queue.pop();
            if(frame_item.has_value()) {
                processNeural(frame_item.value());
            }
        }
        std::cerr << "INFO: Exiting loop-2." << std::endl;
    });
    return 0;
}

void Detector::setCallback(std::function<void(Detection& detection)> v) {
    _onDetection = v;
}

void Detector::pushFrame(FrameItem& frame) {
    _in_frame_queue.push(std::move(frame));
}

void Detector::saveOneFrameTo(std::string path) {
    _save_one_frame_to = path;
}

std::optional<Detection> Detector::getPreviousDetection() {
    return _prev_detection;
}

void Detector::updatePrediction(FrameItem& frameItem) {
    int64 time_start = cv::getTickCount();
    // storage for detections this frame (only filled on inference frames)
    std::vector<cv::Rect> detections;
    std::vector<int> det_class_ids;
    std::vector<float> det_confidences;

    cv::Mat frame = frameItem.frame;

    // --- Predict-only frames (Kalman smoothing) ---
    std::vector<cv::Rect> tracker_boxes;
    std::vector<int> tracker_class_ids;
    std::vector<float> tracker_confidences;

    for (auto &tr : _trackers) {
        // Predict next state
        cv::Mat pred = tr.kf.predict();
        float x = pred.at<float>(0);
        float y = pred.at<float>(1);
        float w = pred.at<float>(2);
        float h = pred.at<float>(3);

        cv::Rect box;
        box.x = static_cast<int>(x);
        box.y = static_cast<int>(y);
        box.width = std::max(1, static_cast<int>(w));
        box.height = std::max(1, static_cast<int>(h));

        // Optional: clamp to frame
        box &= cv::Rect(0, 0, frame.cols, frame.rows);

        // Track aging
        tr.missed_frames++;

        // kill weak + stale trackers early
        if (tr.last_confidence < 0.5f && tr.missed_frames > 3)
            tr.missed_frames = MAX_MISSED_FRAMES + 1;

        // Kill stale trackers
        if (tr.missed_frames > MAX_MISSED_FRAMES)
            continue;

        tracker_boxes.push_back(box);
        tracker_class_ids.push_back(tr.class_id);
        tracker_confidences.push_back(tr.last_confidence);
    }
    // Remove dead trackers
    _trackers.erase(
            std::remove_if(_trackers.begin(), _trackers.end(),
                           [](const Tracker& t) {
                               return t.missed_frames > MAX_MISSED_FRAMES;
                           }),
            _trackers.end()
    );
    // Send predicted (smoothed) results
    send_result(tracker_boxes, tracker_class_ids, tracker_confidences, frame);
}

void Detector::processNeural(FrameItem& frameItem) {
    std::vector<cv::Rect> detections;
    std::vector<int> det_class_ids;
    std::vector<float> det_confidences;
    cv::Mat frame = frameItem.frame;
    std::vector<cv::Mat> outs;
    int64 time_start = cv::getTickCount();
    // --- Pre-processing (Image to Blob) ---
    cv::Mat blob;
    cv::dnn::blobFromImage(frame, blob, 1/255.0, cv::Size(_target_width, _target_height), cv::Scalar(), true, false);
    _net.setInput(blob);

    // --- Inference (Forward Pass) ---
    auto now_start = std::chrono::steady_clock::now();
    try {
        _net.forward(outs, _net.getUnconnectedOutLayersNames());
    } catch (const cv::Exception& e) {
        std::cerr << "OpenCV Forward Error: " << e.what() << std::endl;
    }
    auto now_end = std::chrono::steady_clock::now();
    auto start_ms  = std::chrono::duration_cast<std::chrono::milliseconds>(now_start.time_since_epoch()).count();
    auto end_ms  = std::chrono::duration_cast<std::chrono::milliseconds>(now_end.time_since_epoch()).count();
    LOGD("DETECTION-_net.forward: time lapsed: %dms", end_ms - start_ms);

    // outs[0] is [1, 84, 8400]
    cv::Mat output = outs[0];
    if (output.dims == 3) {
        // Reshape to [84, 8400]
        output = cv::Mat(output.size[1], output.size[2], CV_32F, output.ptr<float>());
    }
    // Transpose it so it becomes [8400, 84] (back to "v5 style" rows)
    cv::Mat data = output.t();

    for (int i = 0; i < data.rows; i++) {
        // In YOLO11, there is no separate "Objectness" score.
        // You find the max class score directly.
        cv::Mat row = data.row(i);
        cv::Mat scores = row.colRange(4, 84); // 80 class scores

        cv::Point class_id_point;
        double max_score;
        minMaxLoc(scores, 0, &max_score, 0, &class_id_point);

        if (max_score > CONF_THRESHOLD) {
            float cx = row.at<float>(0);
            float cy = row.at<float>(1);
            float ow = row.at<float>(2);
            float oh = row.at<float>(3);

            // Standard YOLO scaling
            float x_factor = frame.cols / _target_width;
            float y_factor = frame.rows / _target_height;

            int x = static_cast<int>((cx - 0.5f * ow) * x_factor);
            int y = static_cast<int>((cy - 0.5f * oh) * y_factor);
            int width = static_cast<int>(ow * x_factor);
            int height = static_cast<int>(oh * y_factor);

            detections.push_back(cv::Rect(x, y, width, height));
            det_class_ids.push_back(class_id_point.x);
            det_confidences.push_back(static_cast<float>(max_score));
        }
    }
    // NMS
    std::vector<int> indexes;
    cv::dnn::NMSBoxes(detections, det_confidences, 0.25f, 0.50f, indexes);

    // keep only NMSed lists
    std::vector<cv::Rect> nms_boxes;
    std::vector<int> nms_class_ids;
    std::vector<float> nms_confidences;
    for (int idx : indexes) {
        nms_boxes.push_back(detections[idx]);
        nms_class_ids.push_back(det_class_ids[idx]);
        nms_confidences.push_back(det_confidences[idx]);
    }
    detections.swap(nms_boxes);
    det_class_ids.swap(nms_class_ids);
    det_confidences.swap(nms_confidences);

    // --- Update trackers with detections ---
    processPredictionsAndUpdateTrackers(frame, outs[0], _colors, time_start,
                                        detections, det_class_ids, det_confidences,
                                        _trackers);
    outs.clear();
}

void Detector::send_result(std::vector<cv::Rect>& detections,
                           std::vector<int>& det_class_ids,
                           std::vector<float>& det_confidences,
                           cv::Mat& frame) {
    if (detections.size() != det_class_ids.size() || detections.size() != det_confidences.size()) {
        std::cerr << "Error: Detection result vectors have mismatched sizes." << std::endl;
        return;
    }
    LOGD("📊 FRAME: %dx%d", frame.cols, frame.rows);
    auto now = std::chrono::steady_clock::now();
    Detection detection;
    detection.frame_count = _frame_count;
    detection.timestamp_ns = std::chrono::duration_cast<std::chrono::nanoseconds>(now.time_since_epoch()).count();
    for(int i=0; i<detections.size(); i++) {
        LOGD("📦 RAW detection %d: x=%d, y=%d, w=%d, h=%d",
             i, detections[i].x, detections[i].y,
             detections[i].width, detections[i].height);
        // NORMALIZE!
        float norm_x = detections[i].x / (float)frame.cols;
        float norm_y = detections[i].y / (float)frame.rows;
        float norm_w = detections[i].width / (float)frame.cols;
        float norm_h = detections[i].height / (float)frame.rows;

        LOGD("📏 NORMALIZED %d: x=%.4f, y=%.4f, w=%.4f, h=%.4f",
             i, norm_x, norm_y, norm_w, norm_h);
        DetectionItem item;
        item.x = norm_x;
        item.y = norm_y;
        item.width = norm_w;
        item.height = norm_h;
        item.class_id = det_class_ids[i];
        item.confidence = det_confidences[i];
        detection.detections.push_back(item);
    }
    if(_onDetection) {
        _onDetection(detection);
    }
    _prev_detection = detection;
}

float Detector::iou(const cv::Rect& a, const cv::Rect& b) {
    int x1 = std::max(a.x, b.x);
    int y1 = std::max(a.y, b.y);
    int x2 = std::min(a.x + a.width, b.x + b.width);
    int y2 = std::min(a.y + a.height, b.y + b.height);
    int interW = x2 - x1;
    int interH = y2 - y1;
    if (interW <= 0 || interH <= 0) return 0.0f;
    float interArea = static_cast<float>(interW) * interH;
    float unionA = static_cast<float>(a.width) * a.height + static_cast<float>(b.width) * b.height - interArea;
    return interArea / unionA;
}

cv::Rect Detector::rect_from_state(const cv::Mat& state) {
    // state: [x, y, w, h, vx, vy, vw, vh]^T
    float x = state.at<float>(0);
    float y = state.at<float>(1);
    float w = state.at<float>(2);
    float h = state.at<float>(3);
    cv::Rect r;
    r.x = static_cast<int>(x);
    r.y = static_cast<int>(y);
    r.width = std::max(1, static_cast<int>(w));
    r.height = std::max(1, static_cast<int>(h));
    return r;
}

cv::Mat Detector::state_from_rect(const cv::Rect& r) {
    cv::Mat state = cv::Mat::zeros(8, 1, CV_32F);
    state.at<float>(0) = static_cast<float>(r.x);
    state.at<float>(1) = static_cast<float>(r.y);
    state.at<float>(2) = static_cast<float>(r.width);
    state.at<float>(3) = static_cast<float>(r.height);
    // velocities default 0
    return state;
}

cv::KalmanFilter Detector::create_kalman_for_rect(const cv::Rect& r) {
    int stateSize = 8;
    int measSize = 4;
    int contrSize = 0;
    cv::KalmanFilter kf(stateSize, measSize, contrSize, CV_32F);

    // Transition matrix A
    // [1 0 0 0 1 0 0 0]
    // [0 1 0 0 0 1 0 0]
    // [0 0 1 0 0 0 1 0]
    // [0 0 0 1 0 0 0 1]
    // velocities remain
    kf.transitionMatrix = cv::Mat::eye(stateSize, stateSize, CV_32F);
    kf.transitionMatrix.at<float>(0,4) = 1.0f;
    kf.transitionMatrix.at<float>(1,5) = 1.0f;
    kf.transitionMatrix.at<float>(2,6) = 1.0f;
    kf.transitionMatrix.at<float>(3,7) = 1.0f;

    // Measurement matrix H (maps state to measurements)
    kf.measurementMatrix = cv::Mat::zeros(measSize, stateSize, CV_32F);
    kf.measurementMatrix.at<float>(0,0) = 1.0f; // x
    kf.measurementMatrix.at<float>(1,1) = 1.0f; // y
    kf.measurementMatrix.at<float>(2,2) = 1.0f; // w
    kf.measurementMatrix.at<float>(3,3) = 1.0f; // h

    // Process noise covariance Q
    cv::setIdentity(kf.processNoiseCov, cv::Scalar::all(1e-2f));
    // Measurement noise covariance R
    cv::setIdentity(kf.measurementNoiseCov, cv::Scalar::all(1e-1f));
    // Posterior error covariance P
    cv::setIdentity(kf.errorCovPost, cv::Scalar::all(1.0f));

    // initial state
    cv::Mat initState = state_from_rect(r);
    initState.copyTo(kf.statePost);

    return kf;
}

void Detector::processPredictionsAndUpdateTrackers(cv::Mat& frame, cv::Mat& outs,
                                                   const std::vector<cv::Scalar>& colors,
                                                   int64& time_start,
                                                   std::vector<cv::Rect>& detections,
                                                   std::vector<int>& det_class_ids,
                                                   std::vector<float>& det_confidences,
                                                   std::vector<Tracker>& trackers) {
    // For each tracker predict first (so we can match predictions to detections)
    std::vector<cv::Rect> predicted_boxes;
    predicted_boxes.reserve(trackers.size());
    for (auto &tr : trackers) {
        cv::Mat pred = tr.kf.predict();
        predicted_boxes.push_back(rect_from_state(pred));
    }

    // Build IoU cost matrix
    int T = static_cast<int>(trackers.size());
    int D = static_cast<int>(detections.size());
    std::vector<std::vector<float>> iou_mat(T, std::vector<float>(D, 0.0f));
    for (int t = 0; t < T; ++t) {
        for (int d = 0; d < D; ++d) {
            iou_mat[t][d] = iou(predicted_boxes[t], detections[d]);
        }
    }

    // Greedy matching: pick best IoU pairs until IoU < threshold
    std::vector<int> matchT(T, -1); // tracker -> detection idx, -1 if none
    std::vector<int> matchD(D, -1); // detection -> tracker idx

    while (true) {
        float bestIoU = MATCH_IoU_THRESHOLD;
        int bestT = -1, bestD = -1;
        for (int t = 0; t < T; ++t) {
            for (int d = 0; d < D; ++d) {
                if (matchT[t] != -1 || matchD[d] != -1) continue;
                if (iou_mat[t][d] > bestIoU) {
                    bestIoU = iou_mat[t][d];
                    bestT = t;
                    bestD = d;
                }
            }
        }
        if (bestT == -1) break;
        matchT[bestT] = bestD;
        matchD[bestD] = bestT;
    }

    // Update matched trackers with measurements
    for (int t = 0; t < T; ++t) {
        if (matchT[t] != -1) {
            int d = matchT[t];
            // measurement vector
            cv::Mat meas = cv::Mat::zeros(4,1,CV_32F);
            meas.at<float>(0) = static_cast<float>(detections[d].x);
            meas.at<float>(1) = static_cast<float>(detections[d].y);
            meas.at<float>(2) = static_cast<float>(detections[d].width);
            meas.at<float>(3) = static_cast<float>(detections[d].height);
            trackers[t].kf.correct(meas);
            trackers[t].missed_frames = 0;
            trackers[t].class_id = det_class_ids[d];
            trackers[t].last_confidence = det_confidences[d];
        } else {
            // no detection matched: we already predicted above; mark missed
            trackers[t].missed_frames++;
        }
    }

    // Create trackers for unmatched detections
    for (int d = 0; d < D; ++d) {
        if (matchD[d] == -1) {
            Tracker tr;
            tr.kf = create_kalman_for_rect(detections[d]);
            tr.id = _next_tracker_id++;
            tr.class_id = det_class_ids[d];
            tr.last_confidence = det_confidences[d];
            tr.missed_frames = 0;
            trackers.push_back(std::move(tr));
        }
    }

    // Remove dead trackers
    trackers.erase(std::remove_if(trackers.begin(), trackers.end(),
                                  [](const Tracker& tr) { return tr.missed_frames > MAX_MISSED; }),
                   trackers.end());

    // Draw trackers (using updated states)
    if(!_save_one_frame_to.empty()) {
        drawTrackers(frame, colors, time_start, trackers);
        cv::imwrite(_save_one_frame_to, frame);
        _save_one_frame_to.clear();
    }
}

void Detector::drawTrackers(cv::Mat& frame,
                             const std::vector<cv::Scalar>& colors,
                             int64& time_start,
                             std::vector<Tracker>& trackers) {
    for (auto &tr : trackers) {
        cv::Mat state = tr.kf.statePost; // use posterior if available
        // but if recently predicted (no correct), statePost is still valid; otherwise predict above was called
        cv::Rect box = rect_from_state(state);

        int cls = tr.class_id >= 0 ? tr.class_id : 0;
        float conf = tr.last_confidence;

        // clamp box inside frame
        box &= cv::Rect(0,0,frame.cols, frame.rows);

        cv::rectangle(frame, box, colors[cls % colors.size()], 2, 8);

        std::string label = (tr.class_id >= 0 ? _class_names[tr.class_id] : std::string("obj")) + ": " + cv::format("%.2f", conf);

        cv::rectangle(frame,
                      cv::Point(box.tl().x, box.tl().y - 24),
                      cv::Point(box.br().x, box.tl().y),
                      cv::Scalar(255, 255, 255), -1);

        cv::putText(frame, label,
                    cv::Point(box.tl().x + 2, box.tl().y - 6),
                    cv::FONT_HERSHEY_SIMPLEX, 0.5, cv::Scalar(0,0,0));
    }
//    float t = (cv::getTickCount() - time_start) / static_cast<float>(cv::getTickFrequency());
//    cv::putText(frame, cv::format("FPS: %.2f", 1.0 / t), cv::Point(20, 40), cv::FONT_HERSHEY_PLAIN, 2.0, cv::Scalar(255, 0, 0), 2, 8);
}
