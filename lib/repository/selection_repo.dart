import 'dart:async';
import 'package:flutter_demo/repository/history_rep.dart';
import 'package:loggy/loggy.dart';
import 'package:rxdart/subjects.dart';

class GoToResult {
  GoToResult({required this.model, this.page});
  HistoryRoot model;
  List<HistoryRoot>? page;
}

class SelectionRep {
  final onResult = BehaviorSubject<List<HistoryRoot>>();
  final onBusy = BehaviorSubject<bool>();
  final onMediaMsgCount = BehaviorSubject<int>();
  final selectedStream = BehaviorSubject<List<History>>();
  int get selectedCnt => _selected.length;

  final _selected = <DateTime, History>{};
  final tag = 'selectionRep';

  void dispose() {
    _selected.clear();
    onResult.close();
    onBusy.close();
    onMediaMsgCount.close();
  }

  bool isSelected(History history) {
    return _selected.containsKey(history.date);
  }

  Future stopSelection({bool mounted = true}) async {
    try {
      onBusy.add(false);
      _selected.clear();
      selectedStream.add(_selected.values.toList());
    } catch (ex) {
      logWarning('$tag: stop, ex: [$ex]');
    }
  }

  List<History> getSelected({bool resetSelection = false}) {
    return _selected.values.toList();
  }

  void releaseSelection(History history) {
    _selected.remove(history.date);
    selectedStream.add(_selected.values.toList());
  }

  void addSelection(History history) {
    _selected[history.date] = history;
    selectedStream.add(_selected.values.toList());
  }
}
