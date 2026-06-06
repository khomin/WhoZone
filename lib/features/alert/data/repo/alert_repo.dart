import 'dart:convert';
import 'dart:io';

import 'package:flutter_demo/features/alert/domain/entities/packet.dart';
import 'package:flutter_demo/features/alert/domain/entities/sound.dart';
import 'package:flutter_demo/core/native-api/service_api.dart';
import 'package:flutter_demo/core/repository/constants.dart';
import 'package:injectable/injectable.dart';
import 'package:loggy/loggy.dart';

@lazySingleton
class AlertRep {
  var sounds = <Sound>[];

  final ServiceApi _serviceApi;
  final tag = 'alertRep';

  AlertRep(this._serviceApi) {
    _init();
  }

  Future<void> _init() async {
    sounds = await getSounds();
  }

  Future<List<Sound>> getSounds() async {
    var list = <Sound>[];
    try {
      var r = await _serviceApi.channelCmd
          .invokeMethod('get_system_sounds', <String, dynamic>{});
      r.forEach((key, value) {
        list.add(Sound(name: value['name'], uri: value['uri']));
      });
    } catch (e) {
      logError('$tag: error: $e');
    }
    return list;
  }

  Future<bool> playSound({required Sound sound}) async {
    try {
      var r = await _serviceApi.channelCmd.invokeMethod(
          'play_system_sound', <String, dynamic>{'id': sound.uri}) as bool;
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
}
