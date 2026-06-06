import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_demo/features/alert/domain/entities/packet.dart';
import 'package:flutter_demo/features/alert/domain/entities/sound.dart';

abstract class SettingsRepo {
  ThemeMode getTheme();
  Future<void> setTheme(ThemeMode? theme);

  Future<void> setCameraUsed(String id);
  String? getCameraUsed();

  Duration getCaptureIntervalSec();
  Future<void> setCaptureIntervalSec(Duration v);

  Sound? getCurrentSound();
  Future<void> setCurrentSound(Sound? sound);

  Packet? getPacketUri();
  Future setPacketUri(Packet? packet);

  Future removeAll();
}
