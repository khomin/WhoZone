import 'package:flutter/material.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_svg/svg.dart';

class Button3 extends StatelessWidget {
  const Button3({
    this.text,
    this.colorText,
    this.alignment,
    this.iconData,
    this.iconPath,
    this.padding,
    this.color,
    this.onPressed,
    super.key,
  });
  final String? text;
  final IconData? iconData;
  final String? iconPath;
  final Function()? onPressed;
  final Color? color;
  final Color? colorText;
  final Alignment? alignment;
  final EdgeInsets? padding;

  final height = 20.0;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: padding,
          elevation: 0,
          backgroundColor: color,
          textStyle: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 12,
            color: colorText,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: height),
            if (iconData != null)
              Icon(iconData, color: colorText, size: height),
            if (iconPath != null)
              SvgPicture.asset(
                iconPath!,
                height: height,
                width: height,
                colorFilter: ColorFilter.mode(colorText!, BlendMode.srcIn),
              ),
            if (text != null)
              Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    text!,
                    style: TextStyle(
                      color: colorText,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ))
          ],
        ));
  }
}
