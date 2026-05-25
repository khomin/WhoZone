import 'package:flutter/material.dart';
import 'package:flutter_demo/core/di/di.dart';
import 'package:flutter_demo/features/app/domain/entities/page_type.dart';
import 'package:flutter_demo/repository/settings_rep.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

@injectable
class AppModel with ChangeNotifier {
  bool ready = false;
  bool collapse = false;
  String appVersion = '';
  ThemeMode theme = ThemeMode.system;
  PageType page = PageType.home;
  var _disposed = false;
  final tag = 'appModel';

  AppModel({required this.theme}) {
    _init();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _init() async {
    var packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    notify();
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
