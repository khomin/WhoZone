#ifndef DETECTION_ITEM_H
#define DETECTION_ITEM_H

#include <vector>
#include <algorithm>
#include <opencv2/dnn.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>

struct DetectionItem {
    cv::Rect rect;
    int class_id;
    float confidence;
};

struct Detection {
    uint64_t frame_count;
    int64_t timestamp_ns;
    std::vector<DetectionItem> detections;
};

#endif // DETECTION_ITEM_H
