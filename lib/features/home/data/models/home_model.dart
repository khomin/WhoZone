import 'package:flutter/material.dart';
import 'package:flutter_demo/features/history/domain/entities/history_root.dart';
import 'package:flutter_demo/features/history/domain/entities/history_state.dart';
import 'package:flutter_demo/features/history/domain/repo/history_repo.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

@injectable
class HomeModel with ChangeNotifier {
  HistoryState? historyState;
  final historyStateStream = BehaviorSubject<HistoryState>();
  final swipeReset = ValueNotifier<int>(0);
  final HistoryRepo _historyRep;
  final _disp = DisposableStream();
  var _disposed = false;
  final tag = 'homeModel';

  HomeModel(this._historyRep);

  void init() async {
    final initial = _historyRep.historyRootStream.valueOrNull;
    if (initial != null) {
      historyState = initial;
    }
    _disp.add(_historyRep.historyRootStream.listen((value) {
      historyState = value;
      historyStateStream.add(value);
      notify();
    }));
    _historyRep.updateHistory();
  }

  @override
  void dispose() {
    _disposed = true;
    historyStateStream.close();
    swipeReset.dispose();
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
