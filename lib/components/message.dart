import 'package:flutter/material.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/core/utils/common.dart';

class BottomMessage extends StatelessWidget {
  const BottomMessage({
    required this.type,
    required this.text,
    required this.animated,
    super.key,
  });
  final ToastType type;
  final String text;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    if (!animated) {
      return _body(context);
    }
    return Stack(children: [
      AnimatedPositioned(
        duration: const Duration(seconds: 2),
        child: _body(context),
      )
    ]);
  }

  Widget _body(BuildContext context) {
    var textColor = type == ToastType.error
        ? Theme.of(context).colorScheme.snackColorTextError
        : Theme.of(context).colorScheme.snackColorText;
    var icon = type == ToastType.error
        ? Icon(Icons.error, color: textColor)
        : Icon(Icons.info_outline_rounded, color: textColor);
    return Container(
        padding: animated ? EdgeInsets.only(left: 10, right: 10) : null,
        height: animated ? 40 : null,
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          icon,
          Flexible(
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(
                child: Text(text,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: textColor,
                        shadows: [
                          Shadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 0))
                        ])))
          ]))
        ]));
  }
}
