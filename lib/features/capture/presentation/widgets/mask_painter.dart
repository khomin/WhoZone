import 'package:flutter/material.dart';

class MaskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = Colors.black.withOpacity(0.5);

    // 1. The outer rectangle (whole screen)
    final screenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // 2. The inner cutout (the center 50%)
    double cutoutW = size.width * 0.90;
    double cutoutH = size.height * 0.60;
    double cutoutX = (size.width - cutoutW) / 2;
    double cutoutY = (size.height - cutoutH) / 2;

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cutoutX, cutoutY, cutoutW, cutoutH),
          const Radius.circular(16), // Rounded corners like iOS
        ),
      );

    // 3. Combine them using EvenOdd to create the "hole"
    final perfectMask =
        Path.combine(PathOperation.difference, screenPath, cutoutPath);
    canvas.drawPath(perfectMask, backgroundPaint);

    // Draw a nice subtle border around the cutout
    // final borderPaint = Paint()
    //   ..color = Colors.white
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 2.0;
    // canvas.drawPath(cutoutPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
