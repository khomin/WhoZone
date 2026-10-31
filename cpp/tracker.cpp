#include "tracker.h"
#include <algorithm>
#include <cmath>

namespace {

const int HITS_TO_CONFIRM = 2;         // one-frame false positives are never shown
const int FRAMES_TO_SWITCH_CLASS = 3;  // keeps the label from flickering
const float MIN_MATCH_IOU = 0.15f;
const float SMOOTH_CONFIDENCE = 0.3f;

// How long a track survives without a detection. Time based, so it doesn't
// change with the inference rate.
const float MAX_COAST_SEC = 0.6f;
const float MAX_COAST_WEAK_SEC = 0.25f;
const float WEAK_CONFIDENCE = 0.5f;
// After this we stop extrapolating: the object is more likely gone than moving.
const float MAX_VELOCITY_COAST_SEC = 0.15f;

const float POSITION_ACCEL_NOISE = 500.0f; // px/s^2
const float SIZE_ACCEL_NOISE = 300.0f;      // size changes much slower than position

float measurement_noise(float width, float height) {
    // YOLO box edges jitter proportionally to the box size
    float sigma = 1.0f + 0.03f * std::max(width, height);
    return sigma * sigma;
}

float iou(float ax, float ay, float aw, float ah, float bx, float by, float bw, float bh) {
    float iw = std::min(ax + aw, bx + bw) - std::max(ax, bx);
    float ih = std::min(ay + ah, by + bh) - std::max(ay, by);
    if (iw <= 0 || ih <= 0) return 0;
    float inter = iw * ih;
    return inter / (aw * ah + bw * bh - inter);
}

} // namespace

void AxisFilter::init(float value) {
    _x = value;
    _v = 0;
    _p00 = 25.0f;
    _p01 = 0;
    _p11 = 10000.0f; // velocity is unknown at first
}

void AxisFilter::predict(float dt, float accel_noise) {
    _x += _v * dt;
    float q = accel_noise * accel_noise;
    float dt2 = dt * dt;
    _p00 += dt * (2 * _p01 + dt * _p11) + q * dt2 * dt2 / 4;
    _p01 += dt * _p11 + q * dt2 * dt / 2;
    _p11 += q * dt2;
}

void AxisFilter::correct(float measured, float measurement_noise) {
    float s = _p00 + measurement_noise;
    float k0 = _p00 / s;
    float k1 = _p01 / s;
    float innovation = measured - _x;
    _x += k0 * innovation;
    _v += k1 * innovation;
    float p00 = _p00, p01 = _p01;
    _p00 -= k0 * p00;
    _p01 -= k0 * p01;
    _p11 -= k1 * p01;
}

void BoxTracker::reset() {
    _tracks.clear();
    _time_ns = 0;
}

void BoxTracker::update(const std::vector<Measurement>& detections, int64_t frame_time_ns) {
    _time_ns = frame_time_ns;

    // Bring every track to the time of this frame
    for (auto& t : _tracks) {
        float dt = std::max(0.0f, (frame_time_ns - t.updated_ns) * 1e-9f);
        t.cx.predict(dt, POSITION_ACCEL_NOISE);
        t.cy.predict(dt, POSITION_ACCEL_NOISE);
        t.w.predict(dt, SIZE_ACCEL_NOISE);
        t.h.predict(dt, SIZE_ACCEL_NOISE);
        t.updated_ns = frame_time_ns;
    }

    // Greedy best-first matching
    struct Pair { float score; int track; int detection; };
    std::vector<Pair> pairs;
    for (int t = 0; t < (int)_tracks.size(); t++) {
        auto& tr = _tracks[t];
        float tw = std::max(1.0f, tr.w.value());
        float th = std::max(1.0f, tr.h.value());
        float tx = tr.cx.value() - tw / 2;
        float ty = tr.cy.value() - th / 2;
        for (int d = 0; d < (int)detections.size(); d++) {
            auto& det = detections[d];
            float score = iou(tx, ty, tw, th, det.x, det.y, det.width, det.height);
            // Small fast objects (birds) can jump clear of their own box between
            // frames, so a nearby detection of the same class also counts.
            if (score < MIN_MATCH_IOU && det.class_id == tr.class_id) {
                float dx = (det.x + det.width / 2) - tr.cx.value();
                float dy = (det.y + det.height / 2) - tr.cy.value();
                float reach = std::max(tw, th);
                float dist = std::sqrt(dx * dx + dy * dy);
                if (dist < reach) score = MIN_MATCH_IOU * (1.0f - dist / reach) + 1e-3f;
            }
            if (score > 0) pairs.push_back({score, t, d});
        }
    }
    std::sort(pairs.begin(), pairs.end(), [](const Pair& a, const Pair& b) { return a.score > b.score; });

    std::vector<char> track_used(_tracks.size(), 0);
    std::vector<char> detection_used(detections.size(), 0);
    for (auto& p : pairs) {
        if (track_used[p.track] || detection_used[p.detection]) continue;
        track_used[p.track] = 1;
        detection_used[p.detection] = 1;

        auto& t = _tracks[p.track];
        auto& det = detections[p.detection];
        float r = measurement_noise(det.width, det.height);
        t.cx.correct(det.x + det.width / 2, r);
        t.cy.correct(det.y + det.height / 2, r);
        t.w.correct(det.width, r);
        t.h.correct(det.height, r);
        t.hits++;
        t.seen_ns = frame_time_ns;
        t.confidence += SMOOTH_CONFIDENCE * (det.confidence - t.confidence);

        if (det.class_id == t.class_id) {
            t.pending_class = -1;
            t.pending_count = 0;
        } else if (det.class_id == t.pending_class) {
            if (++t.pending_count >= FRAMES_TO_SWITCH_CLASS) {
                t.class_id = det.class_id;
                t.pending_class = -1;
                t.pending_count = 0;
            }
        } else {
            t.pending_class = det.class_id;
            t.pending_count = 1;
        }
    }

    // Remove tracks that have been lost for too long
    _tracks.erase(std::remove_if(_tracks.begin(), _tracks.end(), [&](const Track& t) {
        float missing = (frame_time_ns - t.seen_ns) * 1e-9f;
        return missing > (t.confidence < WEAK_CONFIDENCE ? MAX_COAST_WEAK_SEC : MAX_COAST_SEC);
    }), _tracks.end());

    // Start tracks for new objects
    for (int d = 0; d < (int)detections.size(); d++) {
        if (detection_used[d]) continue;
        auto& det = detections[d];
        Track t;
        t.id = _next_id++;
        t.cx.init(det.x + det.width / 2);
        t.cy.init(det.y + det.height / 2);
        t.w.init(det.width);
        t.h.init(det.height);
        t.class_id = det.class_id;
        t.confidence = det.confidence;
        t.hits = 1;
        t.updated_ns = frame_time_ns;
        t.seen_ns = frame_time_ns;
        _tracks.push_back(t);
    }
}

std::vector<TrackedBox> BoxTracker::visible() const {
    std::vector<TrackedBox> result;
    result.reserve(_tracks.size());
    for (auto& t : _tracks) {
        if (t.hits < HITS_TO_CONFIRM) continue;
        float w = std::max(1.0f, t.w.value());
        float h = std::max(1.0f, t.h.value());
        bool coasting = (_time_ns - t.seen_ns) * 1e-9f > MAX_VELOCITY_COAST_SEC;
        result.push_back({
            t.id,
            t.cx.value() - w / 2,
            t.cy.value() - h / 2,
            w,
            h,
            coasting ? 0.0f : t.cx.velocity(),
            coasting ? 0.0f : t.cy.velocity(),
            t.class_id,
            t.confidence,
        });
    }
    return result;
}
