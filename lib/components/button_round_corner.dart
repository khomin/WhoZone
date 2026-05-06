import 'package:flutter/material.dart';

class ButtonRoundCorner extends StatelessWidget {
  const ButtonRoundCorner({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.radious,
    required this.width,
    this.borderColor,
    super.key,
  });
  final Icon icon;
  final Function() onPressed;
  final double width;
  final Color color;
  final Color? borderColor;
  final BorderRadiusGeometry radious;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        alignment: Alignment.center,
        child: Stack(children: [
          ElevatedButton(
              onPressed: () => onPressed.call(),
              autofocus: false,
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: radious,
                      side: borderColor != null
                          ? BorderSide(width: 1.5, color: borderColor!)
                          : BorderSide.none),
                  padding: null,
                  alignment: Alignment.center,
                  backgroundColor: color,
                  animationDuration: Duration.zero,
                  shadowColor: Colors.transparent,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                  )),
              child: Center(child: icon))
        ]));
  }
}
