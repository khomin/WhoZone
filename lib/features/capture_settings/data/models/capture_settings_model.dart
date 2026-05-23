import 'package:flutter/material.dart';
import 'package:flutter_demo/repository/camera_rep.dart';
import 'package:flutter_demo/repository/settings_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:injectable/injectable.dart';
import 'package:loggy/loggy.dart';

@injectable
class CaptureSettingsModel with ChangeNotifier {
  Duration captureInterval = Duration(seconds: Constants.minCaptIntvalDefault);
  CameraRep _cameraRep;
  SettingsRep _settingsRep;
  var _disposed = false;
  final tag = 'captureSettingsModel';

  CaptureSettingsModel(this._cameraRep, this._settingsRep) {
    logDebug('ddd');
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

  void setCaptureInterval(Duration v) async {
    captureInterval = v;
    _cameraRep.updateConfiguration(captureInterval: captureInterval);
    await _settingsRep.setCaptureIntervalSec(v);
    notify();
  }
}
