import 'dart:async';
import 'package:flutter/material.dart';

class ClickDetector extends StatefulWidget {
  const ClickDetector(
      {super.key,
      required this.onClick,
      required this.onLongClick,
      required this.child});
  final Widget child;

  final Function() onLongClick;
  final Function() onClick;

  @override
  State<ClickDetector> createState() => ClickDetectorState();
}

class ClickDetectorState extends State<ClickDetector>
    with TickerProviderStateMixin {
  Timer? _clickTm;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _clickTm?.cancel();
        _clickTm = Timer(const Duration(milliseconds: 200), () async {
          _clickTm = null;
          widget.onLongClick();
        });
      },
      onTapUp: (_) {
        _clickTm?.cancel();
        if (_clickTm != null) {
          widget.onClick();
        }
      },
      child: widget.child,
    );
  }
}
