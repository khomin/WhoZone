import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/features/history/domain/entities/history_record.dart';
import 'package:flutter_demo/features/history/domain/entities/history_root.dart';
import 'package:flutter_demo/features/history/domain/entities/history_state.dart';
import 'package:flutter_demo/features/history/domain/repo/history_repo.dart';
import 'package:flutter_demo/components/disposable_stream.dart';
import 'package:injectable/injectable.dart';
import 'package:loggy/loggy.dart';

@injectable
class HistoryModel with ChangeNotifier {
  HistoryState historyState = HistoryState(list: []);
  DateTime? _filterDate;
  HistoryRoot? get history => _history;
  var selected = <History>[];
  int get selectedCnt => _selectedMap.length;
  final _selectedMap = <DateTime, History>{};
  HistoryRoot? _history;
  final HistoryRepo _historyRep;
  var _disposed = false;
  final _disp = DisposableStream();
  final tag = 'historyModel';

  HistoryModel(this._historyRep) {
    _disp.add(_historyRep.historyRootStream.listen((v) {
      historyState = v;
      _findHistory();
    }));
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void notify() {
    if (_disposed) return;
    notifyListeners();
  }

  void setFilter(DateTime date) {
    _filterDate = date;
    _findHistory();
  }

  void deleteHistoryRoot(List<HistoryRoot> list) {
    _historyRep.deleteHistoryRoot(list);
  }

  void deleteHistory(List<History> v) {
    _historyRep.deleteHistory(v);
  }

  void share(List<History> v) {
    _historyRep.share(v);
  }

  bool isSelected(History history) {
    return _selectedMap.containsKey(history.date);
  }

  Future stopSelection({bool mounted = true}) async {
    try {
      _selectedMap.clear();
      selected = _selectedMap.values.toList();
      notify();
    } catch (ex) {
      logWarning('$tag: stop, ex: [$ex]');
    }
  }

  List<History> getSelected({bool resetSelection = false}) {
    return _selectedMap.values.toList();
  }

  void releaseSelection(History history) {
    _selectedMap.remove(history.date);
    selected = _selectedMap.values.toList();
    notify();
  }

  void addSelection(History history) {
    _selectedMap[history.date] = history;
    selected = _selectedMap.values.toList();
    notify();
  }

  void _findHistory() {
    final filter = _filterDate;
    if (filter != null) {
      _history = historyState.list.firstWhereOrNull((e) => e.date == filter);
    } else {
      _history = null;
    }
    notify();
  }
}
