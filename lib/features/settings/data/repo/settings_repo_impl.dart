import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_demo/core/repository/constants.dart';
import 'package:flutter_demo/features/alert/domain/entities/packet.dart';
import 'package:flutter_demo/features/alert/domain/entities/sound.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repo/settings_repo.dart';

// class SettingsRep {

@LazySingleton()
class SettingsRepoImpl implements SettingsRepo {
  SharedPreferences prefs;
  final _usedCameraIdKey = 'camera_id';
  final _captIntValSecKey = 'capt_intval_sec';
  final _soundUsedKey = 'soundUsedKey';
  final _packetUsedKey = 'packetUsedKey';
  final _themeKey = 'themeKey';
  final tag = 'settings';

  SettingsRepoImpl(this.prefs);

  @override
  ThemeMode getTheme() {
    var theme = prefs.getInt(_themeKey);
    if (theme == null) {
      return ThemeMode.system;
    }
    return ThemeMode.values[theme];
  }

  @override
  Future<void> setTheme(ThemeMode? theme) async {
    if (theme == null) {
      prefs.remove(_themeKey);
    } else {
      prefs.setInt(_themeKey, theme.index);
    }
  }

  @override
  Future<void> setCameraUsed(String id) async {
    await prefs.setString(_usedCameraIdKey, id);
  }

  @override
  String? getCameraUsed() {
    return prefs.getString(_usedCameraIdKey);
  }

  @override
  Duration getCaptureIntervalSec() {
    return Duration(
        seconds:
            prefs.getInt(_captIntValSecKey) ?? Constants.minCaptIntvalDefault);
  }

  @override
  Future<void> setCaptureIntervalSec(Duration v) async {
    await prefs.setInt(_captIntValSecKey, v.inSeconds);
  }

  @override
  Sound? getCurrentSound() {
    var v = prefs.getString(_soundUsedKey);
    if (v != null) {
      try {
        var mapJson = jsonDecode(v);
        return Sound(name: mapJson['name'], uri: mapJson['uri']);
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<void> setCurrentSound(Sound? sound) async {
    if (sound != null) {
      var map = {'name': sound.name, 'uri': sound.uri};
      var mapJson = jsonEncode(map);
      await prefs.setString(_soundUsedKey, mapJson);
    } else {
      await prefs.remove(_soundUsedKey);
    }
  }

  @override
  Packet? getPacketUri() {
    var v = prefs.getString(_packetUsedKey);
    if (v != null) {
      try {
        var mapJson = jsonDecode(v);
        return Packet(
          address: mapJson['uri'],
          tcp: mapJson['tcp'],
          udp: mapJson['udp'],
        );
      } catch (_) {}
    }
    return null;
  }

  @override
  Future setPacketUri(Packet? packet) async {
    if (packet != null) {
      var map = {'uri': packet.address, 'tcp': packet.tcp, 'udp': packet.udp};
      var mapJson = jsonEncode(map);
      await prefs.setString(_packetUsedKey, mapJson);
    } else {
      await prefs.remove(_packetUsedKey);
    }
  }

  @override
  Future removeAll() async {
    await prefs.remove(_soundUsedKey);
  }
}
