#ifndef DETECTION_ITEM_H
#define DETECTION_ITEM_H

#include <vector>
#include <algorithm>
#include <opencv2/dnn.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>

struct DetectionItem {
    uint64_t frame_count;
    int64_t timestamp_ns;
    std::vector<cv::Rect> detections;
    std::vector<int> class_ids;
    std::vector<float> confidences;
    std::vector<std::string> names;
};

#endif // DETECTION_ITEM_H
