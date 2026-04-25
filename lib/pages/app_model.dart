import 'package:flutter/material.dart';
import 'package:flutter_demo/repository/camera_rep.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppModel with ChangeNotifier {
  bool ready = false;
  bool collapse = false;
  String appVersion = '';
  ThemeMode theme = ThemeMode.system;
  List<HistoryRecord> history = [];
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

  void setHistory(List<HistoryRecord> v) {
    if (history != v) {
      history = [];
      history.addAll(v);
      notifyListeners();
    }
  }

  void setCollapse(bool v) {
    if (v != collapse) {
      collapse = v;
      notifyListeners();
    }
  }
}
