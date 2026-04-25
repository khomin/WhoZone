import 'package:flutter/material.dart';

extension AppColorScheme on ColorScheme {
  bool dark() => brightness == Brightness.dark;

  Color get appBar =>
      dark() ? const Color(0xFF1c1e23) : const Color(0xFFecebf2);
  Color get baseColor1 =>
      dark() ? const Color(0xFF000000) : const Color(0xFFecebf2);

  static Color get bottomBarLight => Color(0xFFecebf2);
  static Color get bottomBarDark => Color(0xFF252525);

  Color get bottomNavBg => dark() ? bottomBarDark : bottomBarLight;
  Color get bottomNavIcon => dark() ? Colors.white38 : const Color(0xFF8ca1b5);
  Color get bottomNavIconSelected =>
      dark() ? buttonOption1 : const Color(0xFF8ca1b5);

  Color get homeCardH1 =>
      dark() ? const Color(0xFFCACACA) : const Color(0xFF43444c);

  Color get chipsBox => dark()
      ? const Color(0xFF1c1e23)
      : const Color.fromARGB(255, 236, 235, 242);
  Color get chip => dark() ? const Color(0xFF1c1e23) : const Color(0xFFecebf2);
  Color get chipActive =>
      dark() ? const Color.fromARGB(255, 75, 85, 134) : const Color(0xFFC0CCFF);

  Color get snackColor => dark()
      ? const Color.fromARGB(255, 82, 70, 152)
      : const Color.fromARGB(255, 204, 189, 255);
  Color get snackColorText =>
      dark() ? const Color(0xFFecebf2) : const Color.fromARGB(255, 28, 28, 28);

  Color get bottomSheet => dark()
      ? const Color(0xFF1c1e23)
      : const Color.fromARGB(255, 238, 238, 238);

  Color get buttonOption1 => const Color(0xFF467C71);
  Color get menuBorderColor => Color.fromARGB(159, 211, 211, 212);

  Color get menuFontColor1 => colorTextAccent;
  Color get menuFontColor2 => colorTextSecond;

  Color get colorBar => Color.fromARGB(255, 213, 212, 232);
  Color get colorCard => Colors.white;
  Color get colorBgUnderCard => Color(0xfff1f2f4);
  Color get colorTextAccent => Colors.black;
  Color get colorTextSecond => Color(0xA0515155);

  Color get colorPrimary => Color.fromARGB(255, 139, 135, 219);
  Color get colorSecondary => Color.fromARGB(255, 170, 167, 225);

  Color get colorButtonBg => Colors.black12;
  Color get colorButton => Colors.black26;

  Color get colorButtonRed => Color.fromARGB(255, 214, 24, 10);
}
