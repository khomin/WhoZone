import 'package:flutter/material.dart';

class ElipseWithText extends StatelessWidget {
  const ElipseWithText({
    required this.text,
    required this.color,
    this.size = const Size(20, 20),
    this.margin,
    super.key,
  });
  final String text;
  final Color color;
  final EdgeInsets? margin;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.tight(size),
      margin: margin,
      child: CustomPaint(
        painter: CutoutTextPainter(
          text: text,
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors
                .black, // The color here doesn't matter, it will be cut out
          ),
        ),
      ),
    );
  }
}

class CutoutTextPainter extends CustomPainter {
  final String text;
  final TextStyle textStyle;

  CutoutTextPainter({required this.text, required this.textStyle});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Create a clean canvas layer tightly bound to the size
    canvas.saveLayer(Offset.zero & size, Paint());

    // 2. Draw the white circle first (This is our "Destination")
    final circlePaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(90), // Keeps it perfectly round
      ),
      circlePaint,
    );

    // 3. Prepare the text
    final textPainter = TextPainter(
      maxLines: 1,
      ellipsis: '.',
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: size.width);

    // Center the text mathematically
    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    // 4. Use dstOut to scratch the text shape OUT of the white circle
    // This prevents it from bleeding into a square background
    final textPaint = Paint()..blendMode = BlendMode.dstOut;

    // Canvas handles switching the blend mode for the text drawing
    canvas.saveLayer(Offset.zero & size, textPaint);
    textPainter.paint(canvas, offset);
    canvas.restore();

    // 5. Bring it all back to the screen
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CutoutTextPainter oldDelegate) =>
      oldDelegate.text != text || oldDelegate.textStyle != textStyle;
}
