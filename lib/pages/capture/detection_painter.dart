import 'package:flutter/material.dart';
import 'package:flutter_demo/pages/capture/detection_box.dart';
import 'package:loggy/loggy.dart';

class CameraPreviewWithOverlay extends StatefulWidget {
  CameraPreviewWithOverlay({required this.boxes});
  final Stream<List<DetectionBox>> boxes;

  @override
  _CameraPreviewWithOverlayState createState() =>
      _CameraPreviewWithOverlayState();
}

class _CameraPreviewWithOverlayState extends State<CameraPreviewWithOverlay> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.boxes,
        builder: (context, snapshot) {
          var detections = snapshot.data;
          if (detections == null || detections.isEmpty) {
            return const SizedBox();
          }
          return CustomPaint(
            painter: DetectionPainter(detections),
            size: Size.infinite,
          );
        });
  }
}

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
      // Access normalizedRect, not direct x,y,w,h
      final rect = box.normalizedRect;

      // Scale coordinates from camera resolution to screen size
      final scaledRect = Rect.fromLTWH(
        rect.left * size.width, // Use rect.left, not box.x
        rect.top * size.height, // Use rect.top, not box.y
        rect.width * size.width, // Use rect.width, not box.w
        rect.height * size.height, // Use rect.height, not box.h
      );

      logDebug(
          'SCALED: left=${scaledRect.left}, top=${scaledRect.top}, right=${scaledRect.right}, bottom=${scaledRect.bottom}');
      logDebug('SCREEN: width=${size.width}, height=${size.height}');

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
