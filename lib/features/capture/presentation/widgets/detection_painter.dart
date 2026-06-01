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
  State<CameraPreviewWithOverlay> createState() =>
      _CameraPreviewWithOverlayState();
}

class _CameraPreviewWithOverlayState extends State<CameraPreviewWithOverlay>
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
              painter:
                  DetectionPainter(boxes, widget.camWidth, widget.camHeight),
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

  DetectionPainter(this.detections, this.camWidth, this.camHeight);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF54C34A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final textStyle = const TextStyle(color: Colors.white, fontSize: 15);

    // 1. Check if the screen is in Portrait mode
    bool isPortrait = size.height > size.width;

    // 2. Swap the camera dimensions so they match the RotatedBox visual size!
    // If portrait, visual width is the smaller number (3096), height is the larger (4128)
    double visualCamWidth = isPortrait ? camHeight : camWidth;
    double visualCamHeight = isPortrait ? camWidth : camHeight;

    // 3. Calculate how BoxFit.cover scales the coordinate space
    double scaleX = size.width / visualCamWidth;
    double scaleY = size.height / visualCamHeight;
    double activeScale = math.max(scaleX, scaleY); // Uniform scale factor

    // 4. Find out exactly how many screen pixels are cropped off the edges
    double offsetX = (visualCamWidth * activeScale - size.width) / 2;
    double offsetY = (visualCamHeight * activeScale - size.height) / 2;

    for (var box in detections) {
      final rect = box.normalizedRect;

      // 5. Transform the normalized values using the swapped, visual dimensions
      double left = (rect.left * visualCamWidth * activeScale) - offsetX;
      double top = (rect.top * visualCamHeight * activeScale) - offsetY;
      double width = rect.width * visualCamWidth * activeScale;
      double height = rect.height * visualCamHeight * activeScale;

      final scaledRect = Rect.fromLTWH(left, top, width, height);
      canvas.drawRect(scaledRect, paint);

      // Draw label (exactly as you had it)
      final textSpan = TextSpan(
        text: '${box.className} ${(box.confidence * 100).toInt()}%',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(scaledRect.left + 10, scaledRect.top - 25));
    }
  }

  @override
  bool shouldRepaint(DetectionPainter oldDelegate) {
    return oldDelegate.detections != detections;
  }
}
