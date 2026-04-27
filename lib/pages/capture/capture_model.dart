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
  int minArea = Constants.minAreaDefault;
  int captureIntervalSec = Constants.minCaptIntvalDefault;
  bool showAreaOnCapture = false;
  bool run = false;
  int devRotation = 0;
  bool flipWait = false;
  bool orientationpWait = false;
  double flipTurns = 0.0;
  Camera? camera;
  SurfaceLayout layout = SurfaceLayout(rotation: 0, ratio: 1);
  SurfaceLayout oldLayout = SurfaceLayout(rotation: 0, ratio: 1);
  var _disposed = false;
  final tag = 'captureModel';

  void init({
    required int minArea,
    required int captureIntervalSec,
    required bool showAreaOnCapture,
  }) {
    this.minArea = minArea;
    this.captureIntervalSec = captureIntervalSec;
    this.showAreaOnCapture = showAreaOnCapture;
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
    run = false;
    camera = null;
    if (shouldNotify) {
      notify();
    }
    await getIt<CameraRep>().stopCamera();
    await getIt<CameraRep>().setCaptureActive(false);
  }

  Future<bool> start() async {
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
    // await getIt<CameraRep>().stopCamera();
    var res = await getIt<CameraRep>().startCamera(
      id: camera.id,
      captureIntervalSec: await SettingsRep().getCaptureIntervalSec(),
      minArea: await SettingsRep().getCaptureMinArea(),
      showAreaOnCapture: await SettingsRep().getCaptureShowArea(),
    );
    if (!res) {
      return false;
    }
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

  // void _updateLastFrame({required String path}) async {
  //   if (_captured == null) {
  //     setState(() {
  //       if (path.isNotEmpty) {
  //         _captured = ClipRRect(
  //             borderRadius: BorderRadius.circular(30.0),
  //             child: Stack(alignment: Alignment.center, children: [
  //               Image.memory(File(path).readAsBytesSync(),
  //                   cacheHeight: 100, cacheWidth: 100, fit: BoxFit.fill)
  //             ]));
  //       } else {
  //         _captured = ClipRRect(
  //             borderRadius: BorderRadius.circular(30.0),
  //             child:
  //                 Stack(alignment: Alignment.center, children: [Container()]));
  //       }
  //       _onRightToLeft = true;
  //       _hasLastCapture = true;
  //     });
  //   } else {
  //     setState(() {
  //       _onLeftToGone = true;
  //       _hasLastCapture = true;
  //     });
  //     Timer(Constants.lastFrameDuration, () {
  //       setState(() {
  //         _onLeftToGone = false;
  //         _captured = null;
  //         _onRightToLeft = false;
  //       });
  //       Timer(Constants.lastFrameDuration, () {
  //         setState(() {
  //           if (path.isNotEmpty) {
  //             _captured = ClipRRect(
  //                 borderRadius: BorderRadius.circular(30.0),
  //                 child: Stack(alignment: Alignment.center, children: [
  //                   Image.memory(File(path).readAsBytesSync(),
  //                       cacheHeight: 100,
  //                       cacheWidth: 100,
  //                       fit: BoxFit.fitHeight)
  //                 ]));
  //           } else {
  //             _captured = ClipRRect(
  //                 borderRadius: BorderRadius.circular(30.0),
  //                 child: Stack(
  //                     alignment: Alignment.center, children: [Container()]));
  //           }
  //           _onRightToLeft = true;
  //         });
  //       });
  //     });
  //   }
  // }

  // void _handleOnSlide() {
  //   if (getIt<CameraRep>().onCaptureTime.valueOrNull == null) return;
  //   if (_ctrSlideTop.isForwardOrCompleted) {
  //     _ctrSlideTop.reverse().orCancel;
  //   } else {
  //     _ctrSlideTop.forward().orCancel;
  //   }
  // }

  void setMinArea(int v) {
    if (minArea != v) {
      minArea = v;
      SettingsRep().setCaptureMinArea(v);
      getIt<CameraRep>().updateConfiguration(
          minArea: minArea,
          captureIntervalSec: captureIntervalSec,
          showAreaOnCapture: showAreaOnCapture);
      notify();
    }
  }

  void setCaptureImageIntVal(int v) {
    if (captureIntervalSec != v) {
      captureIntervalSec = v;
      SettingsRep().setCaptureIntervalSec(v);
      getIt<CameraRep>().updateConfiguration(
          minArea: minArea,
          captureIntervalSec: captureIntervalSec,
          showAreaOnCapture: showAreaOnCapture);
      notify();
    }
  }

  void setShowArea(bool v) {
    if (showAreaOnCapture != v) {
      showAreaOnCapture = v;
      SettingsRep().setCaptureShowArea(v);
      getIt<CameraRep>().updateConfiguration(
          minArea: minArea,
          captureIntervalSec: captureIntervalSec,
          showAreaOnCapture: showAreaOnCapture);
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
    // var camera2 = camera;
    // if (camera2 == null) return;
    // var sensorRotation = camera2.sensor;
    // var rotation = _adjustRotation(
    //     sensorRotation: sensorRotation,
    //     deviceRotation: devRotation,
    //     front: camera2.facing);
    // var size = camera2.size;
    // var ratio = 1.0;
    // if (size != null) {
    //   ratio = size.height / size.width;
    //   ratio = size.height / size.width;
    //   ratio = size.width / size.height;
    // }
    // setSurfaceLayout(SurfaceLayout(rotation: rotation, ratio: ratio));
    // logDebug(
    //     'BTEST:2 rotation=$rotation, devRotation=$devRotation, sensorRotation=$sensorRotation, cam=${camera?.sensor}, ratio=$ratio');
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
