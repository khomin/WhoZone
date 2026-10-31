#ifndef TRACKER_H
#define TRACKER_H

#include <cstdint>
#include <vector>

// Plain C++ on purpose: no OpenCV, so it can be tested off-device.
// All coordinates are frame pixels, all velocities are pixels per second.

struct Measurement {
    float x, y, width, height; // top-left corner + size
    int class_id;
    float confidence;
};

struct TrackedBox {
    int id;
    float x, y, width, height;
    float vx, vy;
    int class_id;
    float confidence;
};

// Constant-velocity Kalman filter for one coordinate.
class AxisFilter {
public:
    void init(float value);
    void predict(float dt, float accel_noise);
    void correct(float measured, float measurement_noise);

    float value() const { return _x; }
    float velocity() const { return _v; }
    // Value at (now + dt), without changing the filter.
    float peek(float dt) const { return _x + _v * dt; }

private:
    float _x = 0, _v = 0;
    float _p00 = 0, _p01 = 0, _p11 = 0;
};

class BoxTracker {
public:
    // Feed one inference result. frame_time_ns is when the frame was taken, so
    // a slow inference can't be mistaken for slow motion.
    void update(const std::vector<Measurement>& detections, int64_t frame_time_ns);
    // Confirmed tracks, in frame_time_ns coordinates of the last update.
    std::vector<TrackedBox> visible() const;
    void reset();
    bool empty() const { return _tracks.empty(); }

private:
    struct Track {
        int id = 0;
        AxisFilter cx, cy, w, h;
        int class_id = 0;
        int pending_class = -1;
        int pending_count = 0;
        float confidence = 0;
        int hits = 0;
        int64_t updated_ns = 0;
        int64_t seen_ns = 0;
    };

    std::vector<Track> _tracks;
    int _next_id = 1;
    int64_t _time_ns = 0;
};

#endif // TRACKER_H
