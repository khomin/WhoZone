import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_demo/pages/capture/detection_box.dart';

class CameraPreviewWithOverlay extends StatefulWidget {
  final Stream<List<DetectionBox>> boxes;

  const CameraPreviewWithOverlay({required this.boxes});

  @override
  State<CameraPreviewWithOverlay> createState() =>
      _CameraPreviewWithOverlayState();
}

class _CameraPreviewWithOverlayState extends State<CameraPreviewWithOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  List<DetectionBox> _lastBoxes = [];
  List<DetectionBox> _currentBoxes = [];
  List<DetectionBox> _displayBoxes = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );
    // Update _displayBoxes on every animation tick, but without calling setState
    // because AnimatedBuilder will rebuild automatically.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<DetectionBox> _interpolate(
    List<DetectionBox> from,
    List<DetectionBox> to,
    double t,
  ) {
    final result = <DetectionBox>[];
    final maxLen = to.length > from.length ? to.length : from.length;
    for (int i = 0; i < maxLen; i++) {
      final toBox = i < to.length ? to[i] : null;
      final fromBox = i < from.length ? from[i] : null;
      if (toBox == null) continue;
      final fromRect = fromBox?.normalizedRect ?? toBox.normalizedRect;
      final interpRect = Rect.fromLTRB(
        fromRect.left + (toBox.normalizedRect.left - fromRect.left) * t,
        fromRect.top + (toBox.normalizedRect.top - fromRect.top) * t,
        fromRect.right + (toBox.normalizedRect.right - fromRect.right) * t,
        fromRect.bottom + (toBox.normalizedRect.bottom - fromRect.bottom) * t,
      );
      result.add(DetectionBox(
        classId: toBox.classId,
        className: toBox.className,
        confidence: toBox.confidence,
        normalizedRect: interpRect,
        // frameCount: toBox.frameCount,
        // timestamp: toBox.timestamp,
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DetectionBox>>(
      stream: widget.boxes,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final newBoxes = snapshot.data!;
          // Update references when new data arrives
          _lastBoxes = _currentBoxes;
          _currentBoxes = newBoxes;
          // Restart animation (this does NOT cause setState)
          _controller.stop();
          _controller.value = 0.0;
          _controller.forward();
        }

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Compute interpolated boxes directly from current state
            final boxes =
                _interpolate(_lastBoxes, _currentBoxes, _controller.value);
            if (boxes.isEmpty) return const SizedBox();
            return CustomPaint(
              painter: DetectionPainter(boxes),
              size: Size.infinite,
            );
          },
        );
      },
    );
  }
}

// class CameraPreviewWithOverlay extends StatefulWidget {
//   CameraPreviewWithOverlay({required this.boxes});
//   final Stream<List<DetectionBox>> boxes;

//   @override
//   _CameraPreviewWithOverlayState createState() =>
//       _CameraPreviewWithOverlayState();
// }

// class _CameraPreviewWithOverlayState extends State<CameraPreviewWithOverlay> {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//         stream: widget.boxes,
//         builder: (context, snapshot) {
//           var detections = snapshot.data;
//           if (detections == null || detections.isEmpty) {
//             return const SizedBox();
//           }
//           return CustomPaint(
//             painter: DetectionPainter(detections),
//             size: Size.infinite,
//           );
//         });
//   }
// }

class DetectionPainter extends CustomPainter {
  final List<DetectionBox> detections;

  DetectionPainter(this.detections);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final textStyle = TextStyle(color: Colors.white, fontSize: 14);

    for (var box in detections) {
      final rect = box.normalizedRect;

      // Scale coordinates from camera resolution to screen size
      final scaledRect = Rect.fromLTWH(
        rect.left * size.width,
        rect.top * size.height,
        rect.width * size.width,
        rect.height * size.height,
      );
      canvas.drawRect(scaledRect, paint);

      // Draw label
      final textSpan = TextSpan(
        text: '${box.className} ${(box.confidence * 100).toInt()}%',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(scaledRect.left, scaledRect.top - 20));
    }
  }

  @override
  bool shouldRepaint(DetectionPainter oldDelegate) {
    return oldDelegate.detections != detections;
  }
}
