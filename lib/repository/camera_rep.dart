import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/native-api/protobuf/app.pb.dart' as app;
import 'package:flutter_demo/pages/capture/detection_box.dart';
import 'package:flutter_demo/repository/settings_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/utils/file_utils.dart';
import 'package:loggy/loggy.dart';
import 'package:rxdart/rxdart.dart';

class CaptureTime {
  CaptureTime({required this.duration, required this.isFirstEv});
  Duration duration;
  bool isFirstEv;
}

class StartResult {
  StartResult(this.textureId);
  int? textureId;
}

class CameraRep {
  var cameras = <String, app.CameraInfo>{};
  final onCameraChanged = BehaviorSubject<void>();
  final onFrameSize = BehaviorSubject<Size>.seeded(const Size(0, 0));
  final onCaptureTime = BehaviorSubject<CaptureTime?>();
  var onDetection = StreamController<List<DetectionBox>>.broadcast();
  final onTexture = BehaviorSubject<int>();
  final onHistoryDataSize = BehaviorSubject<Int64>.seeded(Int64.ZERO);
  bool captureActive = false;
  Size? targetSize;
  Function(String path)? onCapture;
  Function()? onFirstFrame;
  var _frameSize = const Size(0, 0);
  Timer? _captureTm;
  DateTime? _captureStart;
  Completer<String>? _complCaptOneFrame;
  int _captureIntervalSec = 0;
  DateTime? _prevDetectionTime;
  final _channelCmd = MethodChannel('channel_cmd');
  List<String> _classNames = [];
  var _inited = false;
  final tag = 'myRep';

  Future<void> init() async {
    if (_inited) return;
    targetSize = await getTargetSize();
    final data = await rootBundle.loadString('assets/coco.names');
    _classNames = data.split('\n');
    _inited = true;
  }

  Future<Map<String, app.CameraInfo>> getCameras() async {
    try {
      var res =
          await _channelCmd.invokeMethod('get_cameras', <String, dynamic>{});
      res as Map;
      for (var key in res.keys) {
        var camera = app.CameraInfo.fromBuffer(res[key]);
        cameras[key] = camera;
      }
      onCameraChanged.add(null);
      return cameras;
    } catch (e) {
      logError('$tag: error: $e');
    }
    return cameras;
  }

  Future<StartResult?> startCamera({
    required String id,
    required int captureIntervalSec,
  }) async {
    try {
      // permissions
      var r = await _channelCmd
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
      var textRes =
          await _channelCmd.invokeMethod('register_texture', <String, dynamic>{
        'width': size.width,
        'height': size.height,
      });
      // start camera
      var textureId = textRes['id'] as int;
      await _channelCmd.invokeMethod('start_camera', <String, dynamic>{
        'camera_id': id,
        'texture_id': textureId,
      });
      _frameSize = Size(size.width.toDouble(), size.height.toDouble());
      onTexture.add(textureId);
      onFrameSize.add(_frameSize);
      return StartResult(textureId);
    } on PlatformException catch (e) {
      logError('$tag: error: ${e.message}');
    }
    return null;
  }

  Future<void> stopCamera() async {
    try {
      await _channelCmd.invokeMethod('stop_camera', <String, dynamic>{});
    } on PlatformException catch (e) {
      logError('$tag: error: ${e.message}');
    }
  }

  Future<void> updateConfiguration({
    required int captureIntervalSec,
  }) async {
    _captureIntervalSec = captureIntervalSec;
  }

  void detection(app.Detection ev) {
    final boxes = <DetectionBox>[];
    for (var item in ev.item) {
      boxes.add(DetectionBox.fromProto(item, _classNames));
    }
    final now = DateTime.now();
    var prevTime = _prevDetectionTime;
    if (prevTime != null) {
      var distance = now.difference(prevTime);
      // logDebug(
      //     '$tag: detection: [${boxes.length}], elapsed: ${distance.inMicroseconds}');
      if (distance.inSeconds >= _captureIntervalSec) {
        _alertEvent();
      }
    }
    _prevDetectionTime = now;
    onDetection.add(boxes);
  }

  Future<int> getDeviceSensor() async {
    try {
      var rotation = await _channelCmd
          .invokeMethod('get_device_sensor', <String, dynamic>{});
      return rotation;
    } catch (e) {
      logError('$tag: error: $e');
    }
    return 0;
  }

  Future<void> setCaptureActive(bool v) async {
    if (captureActive != v) {
      captureActive = v;
      if (captureActive) {
        _captureStart = DateTime.now();
        _captureTm = Timer.periodic(const Duration(seconds: 1), (timer) {
          var duration = (_captureStart?.difference(DateTime.now()).abs()) ??
              Duration.zero;
          onCaptureTime.add(CaptureTime(duration: duration, isFirstEv: false));
        });
        onCaptureTime
            .add(CaptureTime(duration: const Duration(), isFirstEv: true));
      } else {
        _captureTm?.cancel();
        _captureStart = null;
        onCaptureTime.add(null);
      }
      try {
        await _channelCmd.invokeMethod(
            'set_capture_active', <String, dynamic>{'active': captureActive});
      } catch (e) {
        logError('$tag: set capture active ex: $e');
      }
    }
  }

  Future<String> captureOneFrame({bool serviceFrame = false}) async {
    var completer = Completer<String>();
    try {
      await _channelCmd.invokeMethod('capture_one_frame',
          <String, dynamic>{'service_frame': serviceFrame});
    } catch (e) {
      logError('$tag: capture one frame ex: $e');
    }
    _complCaptOneFrame?.complete('');
    _complCaptOneFrame = completer;
    return completer.future;
  }

  Future<List<Sound>> getSounds() async {
    var list = <Sound>[];
    try {
      var r = await _channelCmd
          .invokeMethod('get_system_sounds', <String, dynamic>{});
      r.forEach((key, value) {
        list.add(Sound(name: value['name'], uri: value['uri']));
      });
    } catch (e) {
      logError('$tag: error: $e');
    }
    return list;
  }

  Future<bool> playSound({required String sound}) async {
    try {
      var r = await _channelCmd.invokeMethod(
          'play_system_sound', <String, dynamic>{'id': sound}) as bool;
      return r;
    } catch (e) {
      logError('$tag: error: $e');
    }
    return false;
  }

  void sendPacket(Packet packet) async {
    try {
      if (!packet.tcp && !packet.udp) {
        return;
      }
      var now = DateTime.now().millisecondsSinceEpoch;
      var message = '${Constants.packetPrefix}/$now';
      if (packet.tcp) {
        Socket socket =
            await Socket.connect(packet.address, Constants.packetPort);
        socket.write(message);
        await socket.close();
      } else if (packet.udp) {
        var socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
        List<int> data = utf8.encode(message);
        socket.send(
            data, InternetAddress(packet.address), Constants.packetPort);
        socket.close();
      }
    } catch (ex) {
      logError('$tag: error: $ex');
    }
  }

  Future<void> saveOneFrame() async {
    try {
      var path = await Utils.getDowloadPath('who-zone-temp/one_frame.jpeg');
      await _channelCmd.invokeMethod('save_one_frame', <String, dynamic>{
        'path': path,
      });
    } catch (e) {
      logError('$tag: error: $e');
    }
  }

  Future<Size?> getTargetSize() async {
    try {
      var res = await _channelCmd
          .invokeMethod('get_model_target_size', <String, dynamic>{});
      res as Map;
      return Size(res['width'].toDouble(), res['height'].toDouble());
    } catch (e) {
      logError('$tag: error: $e');
    }
    return null;
  }

  void _alertEvent() async {
    // handle if sound enabled
    var sound = await SettingsRep().getSoundUsed();
    if (sound != null) {
      playSound(sound: sound.uri);
    }
    // handle if packet sending enabled
    var packet = await SettingsRep().getPacketUriUsed();
    if (packet != null) {
      sendPacket(packet);
    }
  }
}

class Sound {
  Sound({required this.name, required this.uri});
  final String name;
  final String uri;
}

class Packet {
  Packet({required this.address, required this.tcp, required this.udp});
  final String address;
  final bool tcp;
  final bool udp;
}
