import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_demo/features/history/domain/entities/history_root.dart';
import 'package:injectable/injectable.dart';

@injectable
class FilterModel with ChangeNotifier {
  bool busy = false;
  List<HistoryRoot> result = [];
  String? search;
  Timer? _searchThrottleTm;
  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _searchThrottleTm?.cancel();
    super.dispose();
  }

  void notify() {
    if (_disposed) return;
    notifyListeners();
  }

  void setSearchBusy(bool v) {
    if (busy != v) {
      busy = v;
      notifyListeners();
    }
  }

  void setHistory(List<HistoryRoot> v) {
    if (result != v) {
      result = [];
      result.addAll(v);
      notifyListeners();
    }
  }
}
