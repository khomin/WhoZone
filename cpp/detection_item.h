#ifndef DETECTION_ITEM_H
#define DETECTION_ITEM_H

#include <cstdint>
#include <vector>

struct DetectionItem {
    float x, y, width, height;
    float velocity_x, velocity_y;
    int track_id;
    int class_id;
    float confidence;
};

struct Detection {
    uint64_t frame_count;
    int64_t timestamp_ns;
    std::vector<DetectionItem> detections;
};

#endif // DETECTION_ITEM_H
