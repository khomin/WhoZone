#ifndef FRAME_ITEM_H
#define FRAME_ITEM_H

#include <opencv2/core.hpp>

struct FrameItem {
    cv::Mat frame;
    int64_t timestamp; // steady clock ns, when the frame was received
};

#endif // FRAME_ITEM_H
