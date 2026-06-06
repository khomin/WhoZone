import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
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

class _State extends State<CameraPreviewWithOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  List<DetectionBox> _lastBoxes = [];
  List<DetectionBox> _currentBoxes = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );
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
          _lastBoxes = _currentBoxes;
          _currentBoxes = newBoxes;
          _controller.stop();
          _controller.value = 0.0;
          _controller.forward();
        }
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final boxes = _interpolate(
              _lastBoxes,
              _currentBoxes,
              _controller.value,
            );
            if (boxes.isEmpty) return const SizedBox();
            return CustomPaint(
              painter: DetectionPainter(
                detections: boxes,
                camWidth: widget.camWidth,
                camHeight: widget.camHeight,
              ),
              size: Size.infinite,
            );
          },
        );
      },
    );
  }
}

class DetectionPainter extends CustomPainter {
  final List<DetectionBox> detections;
  final double camWidth;
  final double camHeight;

  DetectionPainter({
    required this.detections,
    required this.camWidth,
    required this.camHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF54C34A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final textStyle = const TextStyle(color: Colors.white, fontSize: 15);

    bool isPortrait = size.height > size.width;
    double visualCamWidth = isPortrait ? camHeight : camWidth;
    double visualCamHeight = isPortrait ? camWidth : camHeight;

    double scaleX = size.width / visualCamWidth;
    double scaleY = size.height / visualCamHeight;
    double activeScale = math.max(scaleX, scaleY);

    double offsetX = (visualCamWidth * activeScale - size.width) / 2;
    double offsetY = (visualCamHeight * activeScale - size.height) / 2;

    for (var box in detections) {
      final rect = box.normalizedRect;

      // 1. Calculate raw screen coordinates
      double left = (rect.left * visualCamWidth * activeScale) - offsetX;
      double top = (rect.top * visualCamHeight * activeScale) - offsetY;
      double width = rect.width * visualCamWidth * activeScale;
      double height = rect.height * visualCamHeight * activeScale;

      // 2. Clamp the bounding box coordinates so they never physically leave the screen edges
      double clampedLeft = left.clamp(0.0, size.width);
      double clampedTop = top.clamp(0.0, size.height);
      double clampedRight = (left + width).clamp(0.0, size.width);
      double clampedBottom = (top + height).clamp(0.0, size.height);

      final scaledRect =
          Rect.fromLTRB(clampedLeft, clampedTop, clampedRight, clampedBottom);

      // Only draw the box if it's actually visible on screen
      if (scaledRect.width > 0 && scaledRect.height > 0) {
        canvas.drawRect(scaledRect, paint);
      }

      // 3. Prepare the text layout ahead of time so we know its dimensions
      final textSpan = TextSpan(
        text: '${box.className} ${(box.confidence * 100).toInt()}%',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Define some padding so the text isn't suffocated by the box edges
      const double paddingH = 8.0;
      const double paddingV = 4.0;

      // 4. Smart Label Positioning (Prevents text going off-screen)
      // We adjust the height calculation slightly to include our new vertical padding
      double labelTop = scaledRect.top - textPainter.height - (paddingV * 2);
      double labelLeft = scaledRect.left;

      // If the object is too close to the top edge, flip the label INSIDE the box
      if (labelTop < 0) {
        labelTop = scaledRect.top;
      }

      // If the object is too close to the right edge, push it left
      if (labelLeft + textPainter.width + (paddingH * 2) > size.width) {
        labelLeft = size.width - textPainter.width - (paddingH * 2);
      }
      labelLeft = labelLeft.clamp(0.0, size.width);

      // 5. DRAW THE OpenCV SOLID BACKGROUND BOX
      final backgroundPaint = Paint()
        ..color = const Color(0xFF54C34A) // Match your bounding box green
        ..style = PaintingStyle.fill; // Fill it up!

      final backgroundRect = Rect.fromLTWH(
        labelLeft,
        labelTop,
        textPainter.width + (paddingH * 2), // Text width + left/right padding
        textPainter.height + (paddingV * 2), // Text height + top/bottom padding
      );

      // Draw the solid green background tag
      canvas.drawRect(backgroundRect, backgroundPaint);

      // 6. PAINT THE TEXT ON TOP
      // Shift the text offset slightly down and right so it centers inside the padding
      textPainter.paint(
        canvas,
        Offset(labelLeft + paddingH, labelTop + paddingV),
      );
    }
  }

  @override
  bool shouldRepaint(DetectionPainter oldDelegate) => true;
}
