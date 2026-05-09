import 'package:flutter/material.dart';

class RoundBox extends StatelessWidget {
  const RoundBox({
    required this.text,
    required this.color,
    this.useLeftMargin = true,
    this.useRightMargin = true,
    required this.borderRadius,
    super.key,
  });
  final bool useLeftMargin;
  final bool useRightMargin;
  final String text;
  final double borderRadius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(
          left: useLeftMargin ? 8 : 0,
          right: useRightMargin ? 8 : 0,
        ),
        decoration: BoxDecoration(
            color: color,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
        child: Center(
            child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        )));
  }
}
