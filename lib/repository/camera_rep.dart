import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/components/semaphore.dart';
import 'package:flutter_demo/native-api/protobuf/app.pb.dart' as app;
import 'package:flutter_demo/repository/settings_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/utils/common.dart';
import 'package:flutter_demo/utils/file_utils.dart';
import 'package:jiffy/jiffy.dart';
import 'package:loggy/loggy.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:collection/collection.dart';

class HistoryRecord with ChangeNotifier {
  HistoryRecord(
      {required this.date,
      required this.dateHeader,
      required this.dateSub,
      required this.dateMonth,
      required this.items,
      required this.path,
      required this.folderName});
  DateTime date;
  String dateHeader;
  String dateSub;
  String dateMonth;
  String folderName;
  String path;
  List<HistoryRecord> items;
  bool get selection => _selection;
  set selection(bool v) {
    _selection = v;
    notifyListeners();
  }

  bool _selection = false;
}

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
  bool captureActive = false;
  final onFrameSize = BehaviorSubject<Size>.seeded(const Size(0, 0));
  final onCaptureTime = BehaviorSubject<CaptureTime?>();
  final onHistory = BehaviorSubject<List<HistoryRecord>>();
  final onTexture = BehaviorSubject<int>();
  var historyCache = <HistoryRecord>[];
  final onHistoryDataSize = BehaviorSubject<Int64>.seeded(Int64.ZERO);
  Function(String path)? onCapture;
  Function()? onFirstFrame;
  final _historySemphore = Semaphore(1);
  var _frameSize = const Size(0, 0);
  Timer? _captureTm;
  DateTime? _captureStart;
  Completer<String>? _complCaptOneFrame;
  static const _channelCmd = MethodChannel('channel_cmd');
  // static const _surfaceChannel = MethodChannel('camera/cmd');
  var _inited = false;
  final tag = 'myRep';

  void init() {
    if (_inited) return;
    // _mainChannel.setMethodCallHandler((call) async {
    //   switch (call.method) {
    //     case 'onCapture':
    //       var path = call.arguments['path'] as String;
    //       logDebug('BTEST_onCapture: $path');
    //       if (path.contains('/service/')) {
    //         _complCaptOneFrame?.complete(path);
    //         _complCaptOneFrame = null;
    //       } else {
    //         onCapture?.call(path);
    //         // handle if sound enabled
    //         var sound = await SettingsRep().getSoundUsed();
    //         if (sound != null) {
    //           playSound(sound: sound.uri);
    //         }
    //         // handle if packet sending enabled
    //         var packet = await SettingsRep().getPacketUriUsed();
    //         if (packet != null) {
    //           sendPacket(packet);
    //         }
    //       }
    //       // getHistory();
    //       break;
    //     case 'onMovement':
    //       logDebug('BTEST_onMovement');
    //       break;
    //     case 'onFirstFrameNotify':
    //       logDebug('BTEST_onFirstFrameNotify');
    //       onFirstFrame?.call();
    //       break;
    //   }
    // });
    _inited = true;
  }

  void dispose() {
    //
  }

  Future<void> registerView() async {
    try {
      await _channelCmd.invokeMethod('register_view', <String, dynamic>{});
    } catch (e) {
      logError('$tag: error: $e');
    }
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
    required int minArea,
    required int captureIntervalSec,
    required bool showAreaOnCapture,
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
      // var cameraSensorRotation = textRes['sensor'] as int;
      await _channelCmd.invokeMethod('start_camera', <String, dynamic>{
        'camera_id': id,
        'texture_id': textureId,
        // 'camera_sensor_rotation': cameraSensorRotation
        // 'minArea': minArea,
        // 'captureIntervalSec': captureIntervalSec,
        // 'showAreaOnCapture': showAreaOnCapture
      });
      // _frameSize = Size(
      //   (r['size_width'] as int).toDouble(),
      //   (r['size_height'] as int).toDouble(),
      // );
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
    required int minArea,
    required int captureIntervalSec,
    required bool showAreaOnCapture,
  }) async {
    try {
      await _channelCmd.invokeMethod('update_configuration', <String, dynamic>{
        'minArea': minArea,
        'captureIntervalSec': captureIntervalSec,
        'showAreaOnCapture': showAreaOnCapture
      });
    } on PlatformException catch (e) {
      logError('$tag: error: ${e.message}');
    }
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

  Future<List<HistoryRecord>> getHistory() async {
    await _historySemphore.acquire();
    var path = '${FileUtils.homeDir}/gallery/';
    historyCache = [];
    var dataSize = Int64();
    try {
      var dir = Directory(path);
      var folders = await dir.list().toList();
      var mapByYear = <int, Map<int, List<HistoryRecord>>>{};
      var allFiles = <FileSystemEntity>[];
      for (var folder in folders) {
        var files = Directory(folder.path).listSync();
        allFiles.addAll(files);
        for (var file in files) {
          var name = FileUtils.getFileName(file.path);
          var date = Common().parseFileNameToDate(name);
          var dayOfYear = Jiffy.parseFromDateTime(date).dayOfYear;
          if (mapByYear[date.year] == null) {
            mapByYear[date.year] = <int, List<HistoryRecord>>{};
          }
          mapByYear[date.year]?[dayOfYear] = [];
        }
      }
      var now = DateTime.now();
      for (var file in allFiles) {
        var name = FileUtils.getFileName(file.path);
        var date = Common().parseFileNameToDate(name);
        String header = '';
        String sub = '';
        var dateJiffy = Jiffy.parseFromDateTime(date);
        var jiffyNow = Jiffy.parseFromDateTime(now);
        // same year & month & day:
        if (dateJiffy.year == jiffyNow.year &&
            dateJiffy.dayOfYear == jiffyNow.dayOfYear) {
          header = Common().dayOfWeekString(dateJiffy.dayOfWeek);
          sub = 'Today';
        } else if (dateJiffy.year == jiffyNow.year &&
            dateJiffy.month == jiffyNow.month) {
          // same year & month:
          header = Common().dayOfWeekString(dateJiffy.dayOfWeek);
          var dayAgo = jiffyNow.dateTime.day - date.day;
          sub = dayAgo == 1 ? '$dayAgo day ago' : '$dayAgo days ago';
        } else {
          // other year:
          header = Common().dayOfWeekString(dateJiffy.dayOfWeek);
          sub = dateJiffy.year.toString();
        }
        var folderName = file.parent.path;
        dataSize += (await file.stat()).size;
        mapByYear[date.year]?[dateJiffy.dayOfYear]?.add(HistoryRecord(
            date: date,
            dateHeader: header,
            dateSub: sub,
            dateMonth: Common().monthString(date.month),
            folderName: folderName,
            items: [],
            path: file.path));
      }
      mapByYear.forEach((key, valueYear) {
        valueYear.forEach((key, valueDayOfYear) {
          valueDayOfYear.sort((a, b) {
            return a.date.compareTo(b.date);
          });
          var item = valueDayOfYear.first;
          var folderName = File(item.path).parent.path;
          historyCache.add(HistoryRecord(
              date: valueDayOfYear.first.date,
              dateHeader: item.dateHeader,
              dateSub: item.dateSub,
              dateMonth: item.dateMonth,
              folderName: folderName,
              items: valueDayOfYear,
              path: item.path));
        });
      });
      historyCache.sort((a, b) {
        return b.date.compareTo(a.date);
      });
    } catch (ex) {
      logWarning('$tag: ex');
    }
    onHistory.add(historyCache);
    onHistoryDataSize.add(dataSize);
    _historySemphore.release();
    return historyCache;
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

  Future<void> deleteHistoryRoot(List<HistoryRecord> list) async {
    var removeItems = <HistoryRecord>[];
    for (var it in list) {
      for (var it2 in it.items) {
        try {
          removeItems.add(it2);
        } catch (ex) {
          logWarning('$tag: delete [$ex]');
        }
      }
    }
    for (var it in removeItems) {
      // get root item in cache
      var cacheItem = historyCache.firstWhereOrNull((h1) {
        return h1.folderName == it.folderName;
      });
      cacheItem?.items.removeWhere((element) {
        return element.path == it.path;
      });
      await File(it.path).delete();
    }
    historyCache.removeWhere((element) {
      return element.items.isEmpty;
    });
    onHistory.add(historyCache);
  }

  Future<void> deleteHistory(List<HistoryRecord> list) async {
    if (list.isEmpty) return;
    for (var it in list) {
      var v = historyCache.firstWhereOrNull((element) {
        return element.folderName == it.folderName;
      });
      try {
        await File(it.path).delete();
        v?.items.removeWhere((element) {
          return element.path == it.path;
        });
      } catch (ex) {
        logWarning('$tag: delete [$ex]');
      }
    }
    onHistory.add(historyCache);
  }

  void share(List<HistoryRecord> list) {
    if (list.isEmpty) return;
    var listPath = <XFile>[];
    for (var it in list) {
      listPath.add(XFile(it.path));
    }
    Share.shareXFiles(listPath, text: 'Check out this image!');
  }

  void shareApp() {
    Share.shareUri(Uri.parse(Constants.appLink));
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

  Future<void> freeData() async {
    await deleteHistoryRoot(historyCache);
    onHistoryDataSize.add(Int64.ZERO);
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
