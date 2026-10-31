import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_demo/features/capture/presentation/widgets/detection_box.dart';

class CameraPreviewWithOverlay extends StatefulWidget {
  final Stream<List<DetectionBox>> boxes;
  final double camWidth;
  final double camHeight;

  const CameraPreviewWithOverlay({
    required this.boxes,
    required this.camWidth,
    required this.camHeight,
  });

  @override
  State<CameraPreviewWithOverlay> createState() => _State();
}

/// One object on screen. Lives across detections, so a box is only ever
/// animated from its own previous position.
class _Track {
  _Track(DetectionBox box) : rect = box.normalizedRect {
    update(box, Duration.zero);
  }

  Rect rect;
  late DetectionBox target;
  double opacity = 0;
  bool alive = true;
  Duration targetTime = Duration.zero;

  void update(DetectionBox box, Duration now) {
    target = box;
    targetTime = now;
    alive = true;
  }
}

class _State extends State<CameraPreviewWithOverlay>
    with SingleTickerProviderStateMixin {
  static const _follow = 0.045; // seconds, how fast a box catches its target
  static const _maxLead = 0.15; // seconds, how far velocity is trusted
  static const _fade = 0.12; // seconds

  final _tracks = <int, _Track>{};
  final _repaint = ValueNotifier<int>(0);
  late final Ticker _ticker;
  StreamSubscription<List<DetectionBox>>? _subscription;
  Duration _now = Duration.zero;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _subscription = widget.boxes.listen(_onBoxes);
  }

  @override
  void didUpdateWidget(CameraPreviewWithOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.boxes != widget.boxes) {
      _subscription?.cancel();
      _subscription = widget.boxes.listen(_onBoxes);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _ticker.dispose();
    _repaint.dispose();
    super.dispose();
  }

  void _onBoxes(List<DetectionBox> boxes) {
    for (final track in _tracks.values) {
      track.alive = false;
    }
    for (final box in boxes) {
      final track = _tracks[box.trackId];
      if (track == null) {
        _tracks[box.trackId] = _Track(box)..targetTime = _now;
      } else {
        track.update(box, _now);
      }
    }
    if (_tracks.isNotEmpty && !_ticker.isActive) {
      _lastTick = Duration.zero;
      _ticker.start();
    }
  }

  void _onTick(Duration elapsed) {
    _now = elapsed;
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;

    final follow = 1 - math.exp(-dt / _follow);
    _tracks.removeWhere((_, track) {
      final lead = math.min(
        (elapsed - track.targetTime).inMicroseconds / 1e6,
        _maxLead,
      );
      final box = track.target;
      final goal = box.normalizedRect.shift(
        Offset(box.velocityX * lead, box.velocityY * lead),
      );
      track.rect = Rect.lerp(track.rect, goal, follow)!;
      track.opacity =
          (track.opacity + (track.alive ? dt : -dt) / _fade).clamp(0.0, 1.0);
      return !track.alive && track.opacity == 0;
    });

    _repaint.value++;
    // Nothing to animate: the overlay costs nothing until the next object
    if (_tracks.isEmpty) _ticker.stop();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: DetectionPainter(
          tracks: _tracks,
          repaint: _repaint,
          camWidth: widget.camWidth,
          camHeight: widget.camHeight,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class DetectionPainter extends CustomPainter {
  static const _accent = Color(0xFF32FF78);
  static const _labelBackground = Color(0xD90B0F0D);
  static const _paddingH = 9.0;
  static const _paddingV = 5.0;
  static const _labelGap = 6.0;
  static const _dotSize = 6.0;
  static const _dotGap = 6.0;

  // Text layout is by far the slowest thing here, and labels repeat a lot
  static final _labels = <String, TextPainter>{};

  final Map<int, _Track> tracks;
  final double camWidth;
  final double camHeight;

  final _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 2.5;
  final _outline = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  final _fill = Paint()..style = PaintingStyle.fill;

  DetectionPainter({
    required this.tracks,
    required Listenable repaint,
    required this.camWidth,
    required this.camHeight,
  }) : super(repaint: repaint);

  TextPainter _label(String text) {
    if (_labels.length > 200) _labels.clear();
    return _labels.putIfAbsent(text, () {
      return TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (camWidth == 0 || camHeight == 0) return;

    bool isPortrait = size.height > size.width;
    double visualCamWidth = isPortrait ? camHeight : camWidth;
    double visualCamHeight = isPortrait ? camWidth : camHeight;

    double scaleX = size.width / visualCamWidth;
    double scaleY = size.height / visualCamHeight;
    double activeScale = math.max(scaleX, scaleY);

    double offsetX = (visualCamWidth * activeScale - size.width) / 2;
    double offsetY = (visualCamHeight * activeScale - size.height) / 2;

    final screen = Offset.zero & size;
    for (final track in tracks.values) {
      final rect = track.rect;
      final box = Rect.fromLTWH(
        rect.left * visualCamWidth * activeScale - offsetX,
        rect.top * visualCamHeight * activeScale - offsetY,
        rect.width * visualCamWidth * activeScale,
        rect.height * visualCamHeight * activeScale,
      ).intersect(screen);
      if (box.width <= 0 || box.height <= 0) continue;

      _paintBox(canvas, box, track.opacity);
      _paintLabel(canvas, size, box, track);
    }
  }

  void _paintBox(Canvas canvas, Rect box, double opacity) {
    _fill.color = _accent.withValues(alpha: 0.07 * opacity);
    _outline.color = _accent.withValues(alpha: 0.35 * opacity);
    _stroke.color = _accent.withValues(alpha: opacity);

    final radius = math.min(10.0, box.shortestSide / 4);
    final rounded = RRect.fromRectAndRadius(box, Radius.circular(radius));
    canvas.drawRRect(rounded, _fill);
    canvas.drawRRect(rounded, _outline);

    // Corner brackets: readable on any background, and they leave the object visible
    final arm = math.min(22.0, box.shortestSide / 3);
    final corners = Path();
    void corner(Offset at, double dx, double dy) {
      corners
        ..moveTo(at.dx + dx * arm, at.dy)
        ..lineTo(at.dx + dx * radius, at.dy)
        ..quadraticBezierTo(at.dx, at.dy, at.dx, at.dy + dy * radius)
        ..lineTo(at.dx, at.dy + dy * arm);
    }

    corner(box.topLeft, 1, 1);
    corner(box.topRight, -1, 1);
    corner(box.bottomLeft, 1, -1);
    corner(box.bottomRight, -1, -1);
    canvas.drawPath(corners, _stroke);
  }

  void _paintLabel(Canvas canvas, Size size, Rect box, _Track track) {
    final target = track.target;
    final text = _label(
      '${target.className} ${(target.confidence * 100).toInt()}%',
    );
    final width = text.width + _dotSize + _dotGap + _paddingH * 2;
    final height = text.height + _paddingV * 2;

    // Above the box, or inside of it when there is no room on top
    double top = box.top - height - _labelGap;
    if (top < 0) top = box.top + _labelGap;
    final left = math.min(box.left, math.max(0.0, size.width - width));

    final pill = RRect.fromLTRBR(
      left,
      top,
      left + width,
      top + height,
      Radius.circular(height / 2),
    );
    _fill.color = _labelBackground.withValues(
      alpha: _labelBackground.a * track.opacity,
    );
    canvas.drawRRect(pill, _fill);

    _fill.color = _accent.withValues(alpha: track.opacity);
    canvas.drawCircle(
      Offset(left + _paddingH + _dotSize / 2, top + height / 2),
      _dotSize / 2,
      _fill,
    );
    if (track.opacity > 0.5) {
      text.paint(
        canvas,
        Offset(left + _paddingH + _dotSize + _dotGap, top + _paddingV),
      );
    }
  }

  @override
  bool shouldRepaint(DetectionPainter oldDelegate) =>
      oldDelegate.camWidth != camWidth || oldDelegate.camHeight != camHeight;
}
