import 'package:flutter/material.dart';
import 'package:flutter_demo/features/history/domain/entities/history_root.dart';
import 'package:flutter_demo/features/history/domain/entities/history_state.dart';
import 'package:flutter_demo/features/history/domain/repo/history_repo.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

@injectable
class HomeModel with ChangeNotifier {
  HistoryState historyState = HistoryState(list: []);
  final HistoryRepo _historyRep;
  final isEmptyStream = BehaviorSubject<bool>();
  final _disp = DisposableStream();
  var _disposed = false;
  final tag = 'homeModel';

  HomeModel(this._historyRep) {
    _init();

    _disp.add(_historyRep.historyRootStream.listen((value) {
      historyState = value;
      notify();
    }));
  }

  void _init() async {
    if (await _historyRep.isEmpty()) {
      if (_disposed) return;
      isEmptyStream.add(true);
    }
    _historyRep.updateHistory();
  }

  @override
  void dispose() {
    _disposed = true;
    isEmptyStream.close();
    _disp.dispose();
    super.dispose();
  }

  void notify() {
    if (_disposed) return;
    notifyListeners();
  }

  void deleteHistoryRoot(List<HistoryRoot> list) {
    _historyRep.deleteHistoryRoot(list);
  }

  void filterHistory({required DateTime startTime, required DateTime endTime}) {
    _historyRep.updateHistory(
      startTime: startTime,
      endTime: endTime,
    );
  }

  void resetFilter() {
    _historyRep.updateHistory();
  }
}
