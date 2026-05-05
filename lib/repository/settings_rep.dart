import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_demo/repository/camera_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRep {
  final _usedCameraIdKey = 'camera_id';
  final _captIntValSecKey = 'capt_intval_sec';
  final _soundUsedKey = 'soundUsedKey';
  final _packetUsedKey = 'packetUsedKey';
  final _themeKey = 'themeKey';
  final tag = 'settings';

  Future<void> init() async {}

  Future<void> setTheme(ThemeMode? theme) async {
    final prefs = await SharedPreferences.getInstance();
    if (theme == null) {
      prefs.remove(_themeKey);
    } else {
      prefs.setInt(_themeKey, theme.index);
    }
  }

  Future<ThemeMode> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    var theme = prefs.getInt(_themeKey);
    if (theme == null) {
      return ThemeMode.system;
    }
    return ThemeMode.values[theme];
  }

  Future<void> setCameraUsed(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usedCameraIdKey, id);
  }

  Future<String?> getCameraUsed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usedCameraIdKey);
  }

  Future<int> getCaptureIntervalSec() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_captIntValSecKey) ?? Constants.minCaptIntvalDefault;
  }

  Future<void> setCaptureIntervalSec(int v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_captIntValSecKey, v);
  }

  Future<Sound?> getSoundUsed() async {
    final prefs = await SharedPreferences.getInstance();
    var v = prefs.getString(_soundUsedKey);
    if (v != null) {
      try {
        var mapJson = jsonDecode(v);
        return Sound(name: mapJson['name'], uri: mapJson['uri']);
      } catch (_) {}
    }
    return null;
  }

  void setSoundUsed(Sound? sound) async {
    final prefs = await SharedPreferences.getInstance();
    if (sound != null) {
      var map = {'name': sound.name, 'uri': sound.uri};
      var mapJson = jsonEncode(map);
      await prefs.setString(_soundUsedKey, mapJson);
    } else {
      await prefs.remove(_soundUsedKey);
    }
  }

  Future<Packet?> getPacketUriUsed() async {
    final prefs = await SharedPreferences.getInstance();
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
    final prefs = await SharedPreferences.getInstance();
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_soundUsedKey);
  }
}
