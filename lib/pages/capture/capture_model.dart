import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/native-api/protobuf/app.pb.dart';
import 'package:flutter_demo/repository/camera_rep.dart';
import 'package:flutter_demo/repository/settings_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:loggy/loggy.dart';

class SurfaceLayout {
  SurfaceLayout({required this.rotation, required this.ratio});
  int rotation;
  double ratio;
}

class CaptureModel with ChangeNotifier {
  CameraRep _cameraRep;
  SettingsRep _settingsRep;
  int captureIntervalSec = Constants.minCaptIntvalDefault;
  bool recording = false;
  bool flipWait = false;
  bool orientationpWait = false;
  double flipTurns = 0.0;
  Camera? camera;
  int? textureId;
  SurfaceLayout layout = SurfaceLayout(rotation: 0, ratio: 1);
  final _dispStream = DisposableStream();
  var _disposed = false;
  final tag = 'captureModel';

  CaptureModel({
    required this.captureIntervalSec,
    required CameraRep cameraRep,
    required SettingsRep settingsRep,
  })  : _cameraRep = cameraRep,
        _settingsRep = settingsRep {}

  @override
  void dispose() {
    _disposed = true;
    _dispStream.dispose();
    super.dispose();
  }

  void notify() {
    if (_disposed) return;
    notifyListeners();
  }

  void stop({bool shouldNotify = true}) async {
    recording = false;
    camera = null;
    if (shouldNotify) {
      notify();
    }
    await _cameraRep.stopCamera();
    _cameraRep.stopCapture();
  }

  Future<bool> start({bool flip = false}) async {
    var cameras = await _cameraRep.getCameras();
    var usedCameraId = _settingsRep.getCameraUsed();
    var camera = cameras[usedCameraId];
    if (flip) {
      var i = cameras.values.firstWhereOrNull((e) => e != camera);
      camera = i;
    }
    if (camera == null) {
      var i = cameras.values
          .firstWhereOrNull((e) => e.isFront == Constants.isDefaultFront);
      if (i != null) {
        camera = i;
      }
    }
    if (camera == null) {
      logError('$tag: could not find camera');
      return false;
    }
    if (this.camera != null) {
      this.camera = null;
      await _cameraRep.stopCamera();
    }
    var res = await _cameraRep.startCamera(id: camera.id);
    if (res == null) {
      return false;
    }
    textureId = res.textureId;
    this.camera = Camera(
      id: camera.id,
      isFront: camera.isFront,
      sensor: camera.sensorRotation,
      size: camera.cameraSizes.first,
    );
    notify();
    updateRotation();
    await _settingsRep.setCameraUsed(camera.id);
    return true;
  }

  void setCaptureInterval(int v) async {
    captureIntervalSec = v;
    notify();
    _cameraRep.updateConfiguration(
      captureIntervalSec: captureIntervalSec,
    );
    await _settingsRep.setCaptureIntervalSec(v);
  }

  void setFlipWait(bool v) {
    if (flipWait != v) {
      flipWait = v;
      notify();
    }
  }

  Future<void> updateRotation() async {
    var camera = this.camera;
    if (camera == null) {
      logWarning('$tag: update rotation - not camera');
      return;
    }
    var rotation = _adjustRotation(
      sensor: camera.sensor,
      front: camera.isFront,
    );
    var size = camera.size;
    var layoutNew =
        SurfaceLayout(rotation: rotation, ratio: size.width / size.height);
    if (layout.ratio == layoutNew.ratio &&
        layout.rotation == layoutNew.rotation) {
      return;
    }
    layout = layoutNew;
    notify();
  }

  int _adjustRotation({required int sensor, required bool front}) {
    if (front) {
      int rotation = sensor % 360;
      return rotation ~/ 90;
    } else {
      int rotation = sensor % 360;
      return rotation ~/ 90;
    }
  }

  void startCapture() {
    _cameraRep.startCapture(
      captureIntervalSec: _settingsRep.getCaptureIntervalSec(),
    );
    recording = true;
    notify();
  }

  void stopCapture() async {
    _cameraRep.stopCapture();
    recording = false;
    notify();
  }
}
