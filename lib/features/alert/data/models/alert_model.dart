import 'package:flutter/material.dart';
import 'package:flutter_demo/features/alert/domain/entities/packet.dart';
import 'package:flutter_demo/features/alert/domain/entities/sound.dart';
import 'package:flutter_demo/features/alert/domain/repo/alert_repo.dart';
import 'package:flutter_demo/repository/settings_rep.dart';
import 'package:injectable/injectable.dart';
import 'package:loggy/loggy.dart';
import 'package:collection/collection.dart';

@injectable
class AlertModel with ChangeNotifier {
  var useSound = false;
  Sound? sound;
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
    Sound? usedSound = _settingsRep.getSound();
    // all system sounds
    setSoundList(await _alertRep.getSounds());
    if (sounds.isNotEmpty) {
      if (usedSound != null) {
        // check if used is in system sounds
        var found = sounds.firstWhereOrNull((it) {
          return it.uri == usedSound.uri;
        });
        if (found != null) {
          setSound(found);
        } else {
          // take first default
          setSound(sounds.first);
          _settingsRep.setSound(sounds.first);
        }
      }
    } else {
      logError('$tag: no sounds');
    }
    // whether use packet sending
    Packet? packetUri = await _settingsRep.getPacketUri();
    if (packetUri != null) {
      setPacketToAddr(v: packetUri.address, saveConfig: false);
      setUsePacket(value: true, saveConfig: false);
      setPacketValue(v: packetUri.tcp ? 'TCP' : 'UDP', saveConfig: false);
    } else {
      setUsePacket(value: false, saveConfig: false);
    }
  }

  void setSound(Sound? v) {
    if (sound != v) {
      sound = v;
      useSound = v != null;
      _settingsRep.setSound(v);
      notifyListeners();
    }
  }

  void setSoundList(List<Sound> list) {
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
}
