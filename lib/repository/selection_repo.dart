import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_demo/repository/history_rep.dart';
import 'package:loggy/loggy.dart';
import 'package:rxdart/subjects.dart';

enum SearchType { media }

class GoToResult {
  GoToResult({required this.model, this.page});
  HistoryRoot model;
  List<HistoryRoot>? page;
}

class SelectionRep {
  final onResult = BehaviorSubject<List<HistoryRoot>>();
  final onBusy = BehaviorSubject<bool>();
  final onMediaMsgCount = BehaviorSubject<int>();
  final selectedStream = BehaviorSubject<int>();
  final searchNode = FocusNode();
  List<History> history;
  bool active = false;
  int get selectedCnt => selectedStream.valueOrNull ?? 0;
  final tag = 'selectionRep';

  SelectionRep({this.history = const []});

  void dispose() {
    for (var it in history) {
      it.selection = false;
    }
    searchNode.dispose();
    onResult.close();
    onBusy.close();
    onMediaMsgCount.close();
  }

  Future stopSelection({bool mounted = true}) async {
    try {
      onBusy.add(false);
      for (var it in history) {
        it.selection = false;
      }
      active = false;
      selectedStream.add(0);
    } catch (ex) {
      logWarning('$tag: stop, ex: [$ex]');
    }
  }

  List<History> getSelected({
    required SearchType type,
    bool resetSelection = false,
  }) {
    var list = <History>[];
    switch (type) {
      case SearchType.media:
        list = history.where((it) => it.selection).toList();
        break;
    }
    if (list.isEmpty) return [];
    selectedStream.add(0);
    if (resetSelection) {
      for (var it in list) {
        it.selection = false;
      }
    }
    return list;
  }

  void releaseSelection() {
    var v = selectedStream.valueOrNull ?? 0;
    if (v > 0) {
      selectedStream.add(v - 1);
    }
  }

  void addSelection() {
    var v = selectedStream.valueOrNull ?? 0;
    selectedStream.add(v + 1);
  }
}
