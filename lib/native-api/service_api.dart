import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter_demo/native-api/protobuf/app.pb.dart';
import 'package:loggy/loggy.dart';
import 'package:protobuf/protobuf.dart';
import 'package:ffi/ffi.dart';

class ServiceApi {
  static Function(Detection detection)? onDetection;
  static late Function _initApi;
  static late Function _initializeApi;
  static late Function _registerEventPort;
  static late Function _unregisterEventPort;
  static late Function _testMethod;
  int _nativePort = -1;
  static late DynamicLibrary _dylib;

  static late Pointer<NativeFunction<NativeEventPtr>> cbPtr;
  static final Map<int, TaskIsolate> _isolateMap = {};
  static int _isolateUniqueCnt = 0;
  static const tag = 'serviceApi';

  static ServiceApi? _instance;
  factory ServiceApi() {
    _instance ??= ServiceApi._internal();
    return _instance!;
  }

  ServiceApi._internal();

  Future<String?> initLib() async {
    Completer<String?> completer = Completer();
    logInfo('$tag: -init');
    try {
      logInfo('$tag: -init [about to open lib]');
      final libraryPath = 'libWhoZone.so';
      _dylib = DynamicLibrary.open(libraryPath);
      logInfo('$tag: -init [lib opened]');

      _initializeApi = _dylib.lookupFunction<IntPtr Function(Pointer<Void>),
          int Function(Pointer<Void>)>("initDartApiDL");

      _registerEventPort =
          _dylib.lookupFunction<IntPtr Function(Int), int Function(int)>(
              "register_event_port");
      _unregisterEventPort =
          _dylib.lookupFunction<IntPtr Function(Int), int Function(int)>(
              "unregister_event_port");
      _initApi = _dylib
          .lookupFunction<Int Function(Uint32), int Function(int)>("initApi");
      //
      // service callback
      final interactiveCppRequests = ReceivePort()..listen(_handleNativeEvent);
      final int nativePort = interactiveCppRequests.sendPort.nativePort;
      _registerEventPort(nativePort);
      _nativePort = interactiveCppRequests.sendPort.nativePort;
      _initializeApi(NativeApi.initializeApiDLData);

      var out = registerCall(
          cb: (data) {
            logInfo('$tag: -init success');
            completer.complete(null);
          },
          description: 'init');
      _initApi(out.taskId, out.data, out.len);
    } catch (ex) {
      logInfo('$tag: -init failed: ${ex.toString()}');
      completer.complete("Error while starting:\n${ex.toString()}");
    }
    return completer.future;
  }

  void dispose() {
    _unregisterEventPort(_nativePort);
  }

  Future<void> testMethod() async {
    Completer completer = Completer();
    var out = registerCall(
        cb: (p) {
          completer.complete();
        },
        description: 'testMethod');
    _testMethod(out.taskId, out.data, out.len);
    return completer.future;
  }

  // @pragma('vm:entry-point')
  static void _handleNativeEvent(dynamic message) {
    var taskId = message[0];
    var buf = message[1] as Uint8List;
    if (taskId > 0) {
      // a result from isolate -> find the map and call result
      var task = _isolateMap.remove(taskId);
      try {
        task?.callback?.call(buf);
      } catch (ex) {
        logError('$tag: _handleNativeEvent: exception in task: $ex');
      } finally {
        // free allocated native buffer
        if (task?.allocatedData != null) {
          calloc.free(task!.allocatedData!);
          task.allocatedData = null;
        }
      }
    } else {
      // events
      try {
        var ev = EventWrapper.fromBuffer(buf);
        switch (ev.whichMsg()) {
          case EventWrapper_Msg.detection:
            onDetection?.call(ev.detection);
            break;
          case EventWrapper_Msg.notSet:
            break;
        }
      } catch (ex) {
        logError('$tag: _handleNativeEvent: exception in events: $ex');
      }
    }
  }

  static ProtoOut registerCall({
    GeneratedMessage? proto,
    Function(Uint8List data)? cb,
    required String description,
  }) {
    _isolateUniqueCnt++;

    // with proto and task id
    if (proto != null) {
      // logDebug('$tag: registerCall=${proto.runtimeType.toString()}');
      var protoBuf = proto.writeToBuffer();
      var pointer = protoBuf.allocatePointer();
      _isolateMap[_isolateUniqueCnt] = TaskIsolate(
          callback: cb, allocatedData: pointer, description: description);
      return ProtoOut(
          taskId: _isolateUniqueCnt,
          data: pointer,
          len: protoBuf.lengthInBytes);
    }
    // just task id
    _isolateMap[_isolateUniqueCnt] = TaskIsolate(
        callback: cb, allocatedData: null, description: description);
    return ProtoOut(taskId: _isolateUniqueCnt, data: null, len: 0);
  }

  static int getTaskCount() {
    return _isolateMap.length;
  }

  static void printTasks() {
    var i = _isolateMap;
    logDebug('$tag: tasks: ${i.length} START |||||||||||||||||||||||||||');
    i.forEach((key, value) {
      logDebug('$tag: task: key=$key, description=${value.description}');
    });
    logDebug('$tag: tasks: ${i.length} END |||||||||||||||||||||||||||');
  }
}

final class Work extends Opaque {}

typedef NativeEventPtr = Void Function(Pointer<DartResult>);
typedef NativeEventCbType = Void Function(
    Int64 sendPort, Pointer<NativeFunction<NativeEventPtr>>);
typedef StatusCbType = void Function(
    int sendPort, Pointer<NativeFunction<NativeEventPtr>>);

final class DartResult extends Struct {
  @Uint64()
  external int protoLen;
  external Pointer<Uint8> protoBuf;
  @Uint64()
  external int taskId;
}

class ProtoOut {
  ProtoOut({
    required this.taskId,
    required this.data,
    required this.len,
  });
  int taskId;
  Pointer<Uint8>? data;
  int len;
}

class TaskIsolate {
  TaskIsolate({
    required this.callback,
    required this.allocatedData,
    required this.description,
  });
  Function(Uint8List data)? callback;
  Pointer<Uint8>? allocatedData;
  String description;
}

extension Uint8ListBlobConversion on Uint8List {
  /// Allocates a pointer filled with the Uint8List data.
  Pointer<Uint8> allocatePointer() {
    final blob = calloc<Uint8>(length);
    final blobBytes = blob.asTypedList(length);
    blobBytes.setAll(0, this);
    return blob;
  }
}
