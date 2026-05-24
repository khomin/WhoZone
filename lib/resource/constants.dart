import 'package:flutter/src/painting/edge_insets.dart';

enum FlavorType { google }

class AppConfig {
  AppConfig({
    required this.flavor,
    required this.storeUrl,
    required this.canHavePremium,
  });
  final FlavorType flavor;
  final String storeUrl;
  final bool canHavePremium;

  static late AppConfig shared;

  static void instantiate(FlavorType type) {
    switch (type) {
      case FlavorType.google:
        shared = AppConfig(
          flavor: FlavorType.google,
          storeUrl:
              'https://play.google.com/store/apps/details?id=com.vocabyte.app',
          canHavePremium: false,
        );
        break;
    }
  }
}

class Constants {
  static const appName = "WhoZone";
  static var appVersion = '1.0.2';
  static const localFolderName = 'whoZone';
  static const appLink =
      'https://play.google.com/store/apps/details?id=com.who.zone';

  static const isDefaultFront = false;
  static const isTestMode = true;
  static get collapseMenuHeight => 150.0;

  static const duration = Duration(milliseconds: 200);
  static const durationPanel = Duration(milliseconds: 100);
  static const lastFrameDuration = Duration(milliseconds: 150);
  static const animationDuraton = const Duration(milliseconds: 150);

  static String get recordDateFormat => 'yyyy-MM-dd kk-mm-sss';
  static get frameFileExtension => '.jpeg';

  static const menuFontSize1 = 15.0;
  static const menuFontSize2 = 14.0;
  static const menuFontSize3 = 13.0;

  static const fontSize1 = 15.0;
  static const fontSize2 = 14.0;
  static const fontSize3 = 13.0;

  static int minAreaDefault = 2000;
  static int minCaptIntvalDefault = 1;

  static const packetPrefix = 'move';
  static const packetPort = 1000;

  static EdgeInsets get marginCard =>
      EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15);

  static double get menuIconSize => 25;
}
