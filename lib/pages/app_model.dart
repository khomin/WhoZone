import 'package:flutter/material.dart';
import 'package:flutter_demo/main.dart';
import 'package:flutter_demo/repository/settings_rep.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppModel with ChangeNotifier {
  bool ready = false;
  bool collapse = false;
  String appVersion = '';
  ThemeMode theme = ThemeMode.system;
  var _disposed = false;

  AppModel({required this.theme}) {
    Future.microtask(() async {
      var packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;
      notify();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void notify() {
    if (_disposed) return;
    notifyListeners();
  }

  void setReady(bool v) {
    if (v != ready) {
      ready = v;
      notifyListeners();
    }
  }

  void setCollapse(bool v) {
    if (v != collapse) {
      collapse = v;
      notifyListeners();
    }
  }

  void setTheme(ThemeMode v) {
    if (theme != v) {
      theme = v;
      getIt<SettingsRep>().setTheme(v);
      notifyListeners();
    }
  }
}
