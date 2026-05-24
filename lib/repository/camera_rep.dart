import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_demo/core/di/di.dart';
import 'package:flutter_demo/features/alert/domain/repo/alert_repo.dart';
import 'package:flutter_demo/native-api/protobuf/app.pb.dart' as app;
import 'package:flutter_demo/features/capture/presentation/widgets/detection_box.dart';
import 'package:flutter_demo/native-api/service_api.dart';
import 'package:flutter_demo/repository/settings_rep.dart';
import 'package:flutter_demo/utils/utils.dart';
import 'package:injectable/injectable.dart';
import 'package:loggy/loggy.dart';
import 'package:rxdart/rxdart.dart';

class CaptureTime {
  CaptureTime({required this.duration, required this.isFirstEvent});
  Duration duration;
  bool isFirstEvent;
}

class StartResult {
  StartResult(this.textureId);
  int? textureId;
}

@lazySingleton
class CameraRep {
  final cameraStream = BehaviorSubject<void>();
  final frameSizeStream = BehaviorSubject<Size>.seeded(const Size(0, 0));
  final captureTimeStream = BehaviorSubject<CaptureTime?>();
  final detectionStream = StreamController<List<DetectionBox>>.broadcast();
  final detectionEventCount = BehaviorSubject<int>();
  final textureStream = BehaviorSubject<int?>();
  var cameras = <String, app.CameraInfo>{};
  bool captureEnable = false;
  Size? targetSize;

  Function(String path)? onCapture;
  Function()? onFirstFrame;

  var _frameSize = const Size(0, 0);
  int? _textureId;
  Timer? _captureTm;
  DateTime? _captureStartedDate;
  Duration _captureIntervalSec = Duration.zero;
  DateTime? _lastDetectionTime;
  List<String> _classNames = [];
  final ServiceApi _serviceApi;
  final AlertRep _alertRep;
  var _inited = false;
  final tag = 'myRep';

  CameraRep(this._serviceApi, this._alertRep);

  Future<void> init() async {
    if (_inited) return;
    targetSize = await getTargetSize();
    // coco
    final data = await rootBundle.loadString('assets/coco.names');
    _classNames = data.split('\n');
    _inited = true;
  }

  Future<Map<String, app.CameraInfo>> getCameras() async {
    try {
      var res = await _serviceApi.channelCmd
          .invokeMethod('get_cameras', <String, dynamic>{});
      res as Map;
      for (var key in res.keys) {
        var camera = app.CameraInfo.fromBuffer(res[key]);
        cameras[key] = camera;
      }
      cameraStream.add(null);
      return cameras;
    } catch (e) {
      logError('$tag: error: $e');
    }
    return cameras;
  }

  Future<StartResult?> startCamera({required String id}) async {
    try {
      // permissions
      var r = await _serviceApi.channelCmd
          .invokeMethod('request_camera_permissions', <String, dynamic>{});
      if (!r) {
        return null;
      }
      var camera = cameras[id];
      if (camera == null) {
        return null;
      }
      var size = camera.cameraSizes.first;
      for (var i in camera.cameraSizes) {
        logDebug('$tag: start camera, size: [${i.width}x${i.height}]');
      }
      for (var i in camera.fpsRanges) {
        logDebug(
            '$tag: start camera, fps: [lower=${i.lower},upper=${i.upper}]');
      }
      // get texture
      var textRes = await _serviceApi.channelCmd
          .invokeMethod('register_texture', <String, dynamic>{
        'width': size.width,
        'height': size.height,
      });
      // start camera
      var textureId = textRes['id'] as int;
      await _serviceApi.channelCmd
          .invokeMethod('start_camera', <String, dynamic>{
        'camera_id': id,
        'texture_id': textureId,
      });
      _frameSize = Size(size.width.toDouble(), size.height.toDouble());
      _textureId = textureId;
      textureStream.add(textureId);
      frameSizeStream.add(_frameSize);
      return StartResult(textureId);
    } on PlatformException catch (e) {
      logError('$tag: error: ${e.message}');
    }
    return null;
  }

  Future<void> stopCamera() async {
    try {
      await _serviceApi.channelCmd
          .invokeMethod('stop_camera', <String, dynamic>{});
      var textureId = _textureId;
      if (textureId != null) {
        _textureId = null;
        textureStream.add(null);
        await _serviceApi.channelCmd
            .invokeMethod('unregister_texture', <String, dynamic>{
          'id': textureId,
        });
      }
    } on PlatformException catch (e) {
      logError('$tag: error: ${e.message}');
    }
  }

  void updateConfiguration({required Duration captureInterval}) async {
    this._captureIntervalSec = captureInterval;
  }

  void detection(app.Detection ev) {
    final boxes = <DetectionBox>[];
    for (var item in ev.item) {
      boxes.add(DetectionBox.fromProto(item, _classNames));
    }
    if (captureEnable && boxes.isNotEmpty) {
      final now = DateTime.now();
      var lastDetectionTime = _lastDetectionTime;
      if (lastDetectionTime == null ||
          now.difference(lastDetectionTime).inSeconds >=
              _captureIntervalSec.inSeconds) {
        _lastDetectionTime = now;
        detectionEvent();
      }
    }
    detectionStream.add(boxes);
  }

  Future<int> getDeviceSensor() async {
    try {
      var rotation = await _serviceApi.channelCmd
          .invokeMethod('get_device_sensor', <String, dynamic>{});
      return rotation;
    } catch (e) {
      logError('$tag: error: $e');
    }
    return 0;
  }

  void startCapture({required Duration captureInterval}) {
    if (captureEnable) return;
    captureEnable = true;
    _captureIntervalSec = captureInterval;
    _captureStartedDate = DateTime.now();
    _captureTm?.cancel();
    _captureTm = Timer.periodic(const Duration(seconds: 1), (tm) {
      var duration = _captureStartedDate?.difference(DateTime.now()).abs();
      captureTimeStream.add(CaptureTime(
        duration: duration ?? Duration.zero,
        isFirstEvent: false,
      ));
    });
    captureTimeStream.add(CaptureTime(
      duration: const Duration(),
      isFirstEvent: true,
    ));
  }

  void stopCapture() {
    if (!captureEnable) return;
    captureEnable = false;
    _captureStartedDate = null;
    _captureTm?.cancel();
    captureTimeStream.add(null);
    detectionEventCount.add(0);
  }

  Future<Size?> getTargetSize() async {
    try {
      var res = await _serviceApi.channelCmd.invokeMethod(
        'get_model_target_size',
        <String, dynamic>{},
      );
      res as Map;
      return Size(res['width'].toDouble(), res['height'].toDouble());
    } catch (e) {
      logError('$tag: error: $e');
    }
    return null;
  }

  void detectionEvent({bool force = false}) async {
    await _saveFrame();
    if (!force) {
      // handle if sound enabled
      var sound = getIt<SettingsRep>().getSound();
      if (sound != null) {
        _alertRep.playSound(sound: sound.uri);
      }
      // handle if packet sending enabled
      var packet = getIt<SettingsRep>().getPacketUri();
      if (packet != null) {
        _alertRep.sendPacket(packet);
      }
    }
    // update counter
    detectionEventCount.add((detectionEventCount.valueOrNull ?? 0) + 1);
  }

  Future<void> _saveFrame({bool debug = false}) async {
    try {
      String? path;
      if (debug) {
        path = await Utils.getDowloadPath('who-zone-temp/one_frame.jpeg');
      } else {
        var date = _captureStartedDate;
        if (date == null) {
          logWarning('$tag: capture is not running to save frame');
          return;
        }
        path = await Utils().historySession(date);
      }
      await _serviceApi.channelCmd
          .invokeMethod('save_one_frame', <String, dynamic>{
        'path': path,
      });
    } catch (e) {
      logError('$tag: error: $e');
    }
  }
}
