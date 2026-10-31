import 'package:flutter/material.dart';

extension AppColorScheme on ColorScheme {
  bool dark() => brightness == Brightness.dark;

  // One accent across the app, the same green as the detection boxes
  static const accentDark = Color(0xFF32FF78);
  static const accentLight = Color(0xFF0B7A3E);

  static const _backgroundDark = Color(0xFF0E1110);
  static const _backgroundLight = Color(0xFFF5F7F5);
  static const _surfaceDark = Color(0xFF181D1B);
  static const _lineDark = Color(0xFF262C29);
  static const _lineLight = Color(0xFFE3E7E4);
  static const _textDark = Color(0xFFF2F5F3);
  static const _textLight = Color(0xFF101412);
  static const _textSecondDark = Color(0xFF98A29D);
  static const _textSecondLight = Color(0xFF59625D);

  Color get appBar => dark() ? _backgroundDark : _backgroundLight;
  Color get baseColor1 => dark() ? _backgroundDark : _backgroundLight;

  static Color get bottomBarLight => _backgroundLight;
  static Color get bottomBarDark => _backgroundDark;

  Color get bottomNavBg => dark() ? bottomBarDark : bottomBarLight;
  Color get bottomNavIconUnselected => dark() ? _textSecondDark : _textSecondLight;
  Color get bottomNavIconSelected => colorPrimary;

  Color get cameraButtonIcon => Colors.white;

  TextStyle get homeCardH1Style => TextStyle(
        fontSize: 28,
        color: homeCardH1,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      );
  Color get homeCardH1 => dark() ? _textDark : _textLight;

  Color get menuFontColor1 => colorTextAccent;
  Color get menuFontColor2 => colorTextSecond;

  Color get colorBar => dark() ? _backgroundDark : _backgroundLight;
  Color get colorCard => dark() ? _surfaceDark : Colors.white;
  Color get colorBgUnderCard => dark() ? _backgroundDark : _backgroundLight;
  Color get colorTextAccent => dark() ? _textDark : _textLight;
  Color get colorTextSecond => dark() ? _textSecondDark : _textSecondLight;

  Color get colorPrimary => dark() ? accentDark : accentLight;
  Color get colorSecondary => colorPrimary.withValues(alpha: 0.7);

  Color get colorButtonBg => Colors.black12;
  // Sits on the live camera. Solid on purpose, a blur here is redone every frame.
  Color get colorButton => Colors.black.withValues(alpha: 0.5);
  Color get colorButtonBorder => Colors.white.withValues(alpha: 0.2);

  Color get colorButtonRed => const Color(0xFFFF453A);

  Color get chipsBox => colorCard;
  Color get chip => dark() ? _lineDark : _lineLight;
  Color get chipActive => colorPrimary.withValues(alpha: 0.25);

  Color get snackColor => dark() ? _lineDark : _textLight;
  Color get snackColorText => dark() ? _textDark : Colors.white;
  Color get snackColorTextError => dark() ? _textDark : Colors.white;

  Color get bottomSheet => colorCard;

  Color get buttonOption => colorPrimary;
  Color get buttonOptionText => dark() ? _backgroundDark : Colors.white;

  Color get menuBorderColor => dark() ? _lineDark : _lineLight;
}
