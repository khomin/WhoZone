import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/main.dart';
import 'package:flutter_demo/native-api/protobuf/app.pb.dart';
import 'package:flutter_demo/repository/camera_rep.dart';
import 'package:flutter_demo/repository/settings_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:loggy/loggy.dart';

class SurfaceLayout {
  SurfaceLayout({required this.rotation, required this.ratio});
  int rotation;
  double ratio;
}

class CaptureModel with ChangeNotifier {
  int captureIntervalSec = Constants.minCaptIntvalDefault;
  bool recording = false;
  int devRotation = 0;
  bool flipWait = false;
  bool orientationpWait = false;
  double flipTurns = 0.0;
  Camera? camera;
  int? textureId;
  SurfaceLayout layout = SurfaceLayout(rotation: 0, ratio: 1);
  SurfaceLayout oldLayout = SurfaceLayout(rotation: 0, ratio: 1);
  var _disposed = false;
  final tag = 'captureModel';

  CaptureModel();

  void init({required int captureIntervalSec}) {
    this.captureIntervalSec = captureIntervalSec;
    notify();
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

  void stop({bool shouldNotify = true}) async {
    recording = false;
    camera = null;
    if (shouldNotify) {
      notify();
    }
    await getIt<CameraRep>().stopCamera();
    await getIt<CameraRep>().setCaptureActive(false);
  }

  Future<bool> start({bool flip = false}) async {
    var cameras = await getIt<CameraRep>().getCameras();
    var usedCameraId = await SettingsRep().getCameraUsed();
    var camera = cameras[usedCameraId];
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
    var res = await getIt<CameraRep>().startCamera(
        id: camera.id,
        captureIntervalSec: await SettingsRep().getCaptureIntervalSec());
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
    await SettingsRep().setCameraUsed(camera.id);
    return true;
  }

  //   Camera? _cameraToFlit() {
  //   var camera = getIt<CameraRep>().cameras;
  //   var front = camera['front'];
  //   var back = camera['back'];
  //   var cur = _model.camera;
  //   if (front == cur) {
  //     return back;
  //   }
  //   return front;
  // }

  void setCaptureImageIntVal(int v) async {
    if (captureIntervalSec != v) {
      captureIntervalSec = v;
      await SettingsRep().setCaptureIntervalSec(v);
      getIt<CameraRep>().updateConfiguration(
        captureIntervalSec: captureIntervalSec,
      );
      notify();
    }
  }

  void setFlipWait(bool v) {
    if (flipWait != v) {
      flipWait = v;
      notify();
    }
  }

  void setSurfaceLayout(SurfaceLayout v) {
    layout = v;
    notify();
  }

  void updateRotation() {
    var camera = this.camera;
    if (camera == null) {
      logWarning('$tag: update rotation - not camera');
      return;
    }
    var sensorRotation = camera.sensor;
    var rotation = _adjustRotation(
      sensorRotation: sensorRotation,
      deviceRotation: devRotation,
      front: camera.isFront,
    );
    var size = camera.size;
    var ratio = 1.0;
    ratio = size.height / size.width;
    ratio = size.height / size.width;
    ratio = size.width / size.height;
    setSurfaceLayout(SurfaceLayout(rotation: rotation, ratio: ratio));
  }

  int _adjustRotation({
    required int sensorRotation,
    required int deviceRotation,
    required bool front,
  }) {
    if (front) {
      int combinedRotation = (sensorRotation + deviceRotation) % 360;
      return combinedRotation ~/ 90;
    } else {
      int combinedRotation = (sensorRotation - deviceRotation + 360) % 360;
      return combinedRotation ~/ 90;
    }
  }
}
