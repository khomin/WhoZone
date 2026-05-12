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
  Color get bottomNavIconUnselected =>
      dark() ? Color(0xFF6F63AA) : Color(0xFF8476C7);
  Color get bottomNavIconSelected =>
      dark() ? Color(0xFF8181FB) : Color(0xFF2C2C54);

  Color get cameraButtonIcon =>
      dark() ? const Color(0xFFE7E7E7) : const Color(0xFFE7E7E7);

  TextStyle get homeCardH1Style => TextStyle(fontSize: 25, color: homeCardH1);
  Color get homeCardH1 =>
      dark() ? const Color(0xFFCACACA) : const Color(0xFF43444c);

  Color get menuFontColor1 => colorTextAccent;
  Color get menuFontColor2 => colorTextSecond;

  Color get colorBar => dark() ? Color(0xFF252525) : Color(0xFFD5D4E8);
  Color get colorCard => dark() ? const Color(0xFF3D3D3D) : Colors.white;
  Color get colorBgUnderCard => dark() ? Color(0xFF35373B) : Color(0xfff1f2f4);
  Color get colorTextAccent => dark() ? const Color(0xFFE5E5E5) : Colors.black;
  Color get colorTextSecond => dark() ? Color(0xFFADADB6) : Color(0xA0515155);

  Color get colorPrimary => Color.fromARGB(255, 139, 135, 219);
  Color get colorSecondary => Color.fromARGB(255, 170, 167, 225);

  Color get colorButtonBg => Colors.black12;
  Color get colorButton => Colors.black12;

  Color get colorButtonRed => Color.fromARGB(255, 214, 24, 10);

  Color get chipsBox => dark()
      ? const Color(0xFF1c1e23)
      : const Color.fromARGB(255, 236, 235, 242);
  Color get chip => dark() ? const Color(0xFF1c1e23) : const Color(0xFFecebf2);
  Color get chipActive =>
      dark() ? const Color.fromARGB(255, 75, 85, 134) : const Color(0xFFC0CCFF);

  Color get snackColor =>
      dark() ? const Color(0xFF524698) : const Color(0xFFCCBDFF);
  Color get snackColorText =>
      dark() ? const Color(0xFFecebf2) : const Color.fromARGB(255, 28, 28, 28);
  Color get snackColorTextError =>
      dark() ? const Color(0xFFecebf2) : const Color.fromARGB(255, 28, 28, 28);

  Color get bottomSheet => dark()
      ? const Color(0xFF1c1e23)
      : const Color.fromARGB(255, 238, 238, 238);

  Color get buttonOption1 => const Color(0xFF467C71);
  Color get menuBorderColor => Color.fromARGB(159, 211, 211, 212);
}
