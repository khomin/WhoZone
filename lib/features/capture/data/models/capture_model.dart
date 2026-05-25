import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/features/capture/presentation/widgets/detection_box.dart';
import 'package:flutter_demo/core/native-api/protobuf/app.pb.dart';
import 'package:flutter_demo/repository/camera_rep.dart';
import 'package:flutter_demo/repository/settings_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:injectable/injectable.dart';
import 'package:loggy/loggy.dart';

class SurfaceLayout {
  SurfaceLayout({required this.rotation, required this.ratio});
  int rotation;
  double ratio;
}

@injectable
class CaptureModel with ChangeNotifier {
  bool captureEnabled = false;
  bool orientationpWait = false;
  double flipTurns = 0.0;
  bool flipBusy = false;
  Camera? camera;
  Duration? captureTimeElapsed;
  Duration captureInterval = Duration.zero;
  int? textureId;
  int detectionCount = 0;
  var started = false;
  Stream<List<DetectionBox>> get detectionBoxesStream =>
      cameraRep.detectionStream.stream;
  SurfaceLayout layout = SurfaceLayout(rotation: 0, ratio: 1);
  CameraRep cameraRep;
  SettingsRep settingsRep;
  final _dispStream = DisposableStream();
  var _disposed = false;
  final tag = 'captureModel';

  CaptureModel({required this.cameraRep, required this.settingsRep}) {
    captureInterval = settingsRep.getCaptureIntervalSec();
    _dispStream.add(cameraRep.detectionEventCount.stream.listen((v) {
      detectionCount = v;
      notify();
    }));
    _dispStream.add(cameraRep.captureTimeStream.stream.listen((v) {
      captureTimeElapsed = v?.duration;
      notify();
    }));
  }

  @override
  void dispose() {
    _disposed = true;
    _dispStream.dispose();
    stop(fromDispose: true);
    super.dispose();
  }

  void notify() {
    if (_disposed) return;
    notifyListeners();
  }

  void stop({bool fromDispose = false}) async {
    started = false;
    captureEnabled = false;
    camera = null;
    if (!fromDispose) notify();
    await cameraRep.stopCamera();
    cameraRep.stopCapture();
    cameraRep.onCapture = null;
    cameraRep.onFirstFrame = null;
  }

  Future<bool> start({bool flip = false}) async {
    try {
      var cameras = await cameraRep.getCameras();
      var usedCameraId = settingsRep.getCameraUsed();
      var camera = cameras[usedCameraId];
      if (flip) {
        var i = cameras.values.firstWhereOrNull((e) => e != camera);
        camera = i;
        setFlip(true);
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
        await cameraRep.stopCamera();
      }
      var res = await cameraRep.startCamera(id: camera.id);
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
      started = true;
      notify();
      updateRotation();
      await settingsRep.setCameraUsed(camera.id);
    } finally {
      if (flip) {
        setFlip(false);
      }
    }
    return true;
  }

  void setCaptureInterval(Duration v) async {
    captureInterval = v;
    cameraRep.updateConfiguration(captureInterval: captureInterval);
    settingsRep.setCaptureIntervalSec(v);
    notify();
  }

  void setFlip(bool v) {
    if (v) {
      flipTurns += 0.5;
    }
    flipBusy = v;
    notify();
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
    cameraRep.startCapture(
      captureInterval: settingsRep.getCaptureIntervalSec(),
    );
    captureEnabled = true;
    notify();
  }

  void stopCapture() async {
    cameraRep.stopCapture();
    captureEnabled = false;
    notify();
  }

  void makeOneShot() {
    cameraRep.detectionEvent(force: true);
  }
}
