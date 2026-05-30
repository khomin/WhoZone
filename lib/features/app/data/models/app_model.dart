import 'package:flutter/material.dart';
import 'package:flutter_demo/core/di/di.dart';
import 'package:flutter_demo/features/app/domain/entities/page_type.dart';
import 'package:flutter_demo/repository/settings_rep.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

@injectable
class AppModel with ChangeNotifier {
  bool ready = false;
  String appVersion = '';
  ThemeMode theme = ThemeMode.system;
  PageType page = PageType.home;
  final SettingsRep _settingsRep;
  var _disposed = false;
  final tag = 'appModel';

  AppModel(this._settingsRep) {
    _init();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _init() {
    theme = _settingsRep.getTheme();
    Future.microtask(() async {
      var packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;
      notify();
    });
  }

  void notify() {
    if (_disposed) return;
    notifyListeners();
  }

  void setPage(PageType v) {
    page = v;
    notify();
  }

  void setReady(bool v) {
    if (v != ready) {
      ready = v;
      notifyListeners();
    }
  }

  void setTheme(ThemeMode v) {
    if (theme != v) {
      theme = v;
      _settingsRep.setTheme(v);
      notifyListeners();
    }
  }
}
