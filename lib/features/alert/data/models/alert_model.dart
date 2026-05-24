import 'package:flutter/material.dart';
import 'package:flutter_demo/features/alert/domain/entities/packet.dart';
import 'package:flutter_demo/features/alert/domain/entities/sound.dart';
import 'package:flutter_demo/features/alert/data/repo/alert_repo.dart';
import 'package:flutter_demo/repository/settings_rep.dart';
import 'package:injectable/injectable.dart';
import 'package:loggy/loggy.dart';
import 'package:collection/collection.dart';

@injectable
class AlertModel with ChangeNotifier {
  var useSound = false;
  Sound? currentSound;
  var sounds = <Sound>[];
  var usePacket = false;
  var packetValue = 'TCP';
  final packetList = <String>['TCP', 'UDP'];
  String? packetToAddr;

  final SettingsRep _settingsRep;
  final AlertRep _alertRep;

  final tag = 'alertModel';

  AlertModel(this._settingsRep, this._alertRep) {
    _init();
  }

  Future<void> _init() async {
    // whether sound used
    Sound? sound = _settingsRep.getCurrentSound();
    // all system sounds
    setSounds(_alertRep.sounds);
    // set current sound
    if (sounds.isNotEmpty && sound != null) {
      // check if used is in system sounds
      var found = sounds.firstWhereOrNull((it) {
        return it.uri == sound.uri;
      });
      if (found != null) {
        setCurrentSound(found);
      } else {
        // take first default
        setCurrentSound(sounds.first);
        _settingsRep.setCurrentSound(sounds.first);
      }
    } else {
      logError('$tag: no sounds');
    }
    // when use packet sending
    Packet? packetUri = _settingsRep.getPacketUri();
    if (packetUri != null) {
      setPacketToAddr(v: packetUri.address, saveConfig: false);
      setUsePacket(value: true, saveConfig: false);
      setPacketValue(v: packetUri.tcp ? 'TCP' : 'UDP', saveConfig: false);
    } else {
      setUsePacket(value: false, saveConfig: false);
    }
  }

  void setCurrentSound(Sound? v) {
    if (currentSound != v) {
      currentSound = v;
      useSound = v != null;
      _settingsRep.setCurrentSound(v);
      notifyListeners();
    }
  }

  void setSounds(List<Sound> list) {
    if (sounds != list) {
      sounds = list;
      notifyListeners();
    }
  }

  void setUsePacket(
      {required bool value, required bool saveConfig, Packet? packet}) {
    if (usePacket != value) {
      usePacket = value;
      if (value && saveConfig) {
        _settingsRep.setPacketUri(
            packet ?? Packet(address: '192.168.1.1', tcp: true, udp: false));
      } else if (saveConfig) {
        _settingsRep.setPacketUri(null);
      }
      notifyListeners();
    }
  }

  void setPacketValue({required String v, required bool saveConfig}) {
    if (packetValue != v) {
      packetValue = v;
      if (saveConfig) {
        _settingsRep.setPacketUri(Packet(
            address: packetToAddr ?? '',
            tcp: packetValue == 'TCP' ? true : false,
            udp: packetValue == 'UDP' ? true : false));
      }
      notifyListeners();
    }
  }

  void setPacketToAddr({required String? v, required bool saveConfig}) {
    if (packetToAddr != v) {
      packetToAddr = v;
      if (v != null && saveConfig) {
        _settingsRep.setPacketUri(Packet(
            address: v,
            tcp: packetValue == 'TCP' ? true : false,
            udp: packetValue == 'UDP' ? true : false));
      }
      notifyListeners();
    }
  }

  void playSound({required Sound sound}) {
    _alertRep.playSound(sound: sound);
  }
}
