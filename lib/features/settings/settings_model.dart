import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/features/history/domain/repo/history_repo.dart';
import 'package:flutter_demo/components/disposable_stream.dart';
import 'package:injectable/injectable.dart';

@injectable
class SettingsModel with ChangeNotifier {
  var usedDiskSize = Int64.ZERO;
  var _disposed = false;
  final _disp = DisposableStream();
  HistoryRepo _historyRep;
  final tag = 'settingsModel';

  SettingsModel(this._historyRep) {
    _disp.add(_historyRep.usedDiskStream.listen((v) {
      usedDiskSize = Int64(v);
      notify();
    }));
  }

  @override
  void dispose() {
    _disposed = true;
    _disp.dispose();
    super.dispose();
  }

  void notify() {
    if (_disposed) return;
    notifyListeners();
  }

  void freeData() {
    _historyRep.freeData();
  }
}
