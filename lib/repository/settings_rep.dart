import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_demo/repository/camera_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRep {
  SharedPreferences prefs;
  final _usedCameraIdKey = 'camera_id';
  final _captIntValSecKey = 'capt_intval_sec';
  final _soundUsedKey = 'soundUsedKey';
  final _packetUsedKey = 'packetUsedKey';
  final _themeKey = 'themeKey';
  final tag = 'settings';

  SettingsRep(this.prefs);

  Future<void> init() async {}

  ThemeMode getTheme() {
    var theme = prefs.getInt(_themeKey);
    if (theme == null) {
      return ThemeMode.system;
    }
    return ThemeMode.values[theme];
  }

  Future<void> setTheme(ThemeMode? theme) async {
    if (theme == null) {
      prefs.remove(_themeKey);
    } else {
      prefs.setInt(_themeKey, theme.index);
    }
  }

  Future<void> setCameraUsed(String id) async {
    await prefs.setString(_usedCameraIdKey, id);
  }

  String? getCameraUsed() {
    return prefs.getString(_usedCameraIdKey);
  }

  int getCaptureIntervalSec() {
    return prefs.getInt(_captIntValSecKey) ?? Constants.minCaptIntvalDefault;
  }

  Future<void> setCaptureIntervalSec(int v) async {
    await prefs.setInt(_captIntValSecKey, v);
  }

  Sound? getSound() {
    var v = prefs.getString(_soundUsedKey);
    if (v != null) {
      try {
        var mapJson = jsonDecode(v);
        return Sound(name: mapJson['name'], uri: mapJson['uri']);
      } catch (_) {}
    }
    return null;
  }

  Future<void> setSound(Sound? sound) async {
    if (sound != null) {
      var map = {'name': sound.name, 'uri': sound.uri};
      var mapJson = jsonEncode(map);
      await prefs.setString(_soundUsedKey, mapJson);
    } else {
      await prefs.remove(_soundUsedKey);
    }
  }

  Packet? getPacketUri() {
    var v = prefs.getString(_packetUsedKey);
    if (v != null) {
      try {
        var mapJson = jsonDecode(v);
        return Packet(
            address: mapJson['uri'], tcp: mapJson['tcp'], udp: mapJson['udp']);
      } catch (_) {}
    }
    return null;
  }

  Future setPacketUri(Packet? packet) async {
    if (packet != null) {
      var map = {'uri': packet.address, 'tcp': packet.tcp, 'udp': packet.udp};
      var mapJson = jsonEncode(map);
      await prefs.setString(_packetUsedKey, mapJson);
    } else {
      await prefs.remove(_packetUsedKey);
    }
  }

  //
  // remove all stored values
  Future removeAll() async {
    await prefs.remove(_soundUsedKey);
  }
}
