import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_demo/repository/history_rep.dart';
import 'package:injectable/injectable.dart';

@injectable
class FilterModel with ChangeNotifier {
  bool busy = false;
  List<HistoryRoot> result = [];
  String? search;
  Timer? _searchThrottleTm;

  @override
  void dispose() {
    super.dispose();
    _searchThrottleTm?.cancel();
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

  void setSearch(String? v) {
    // _searchThrottleTm?.cancel();
    // _searchThrottleTm = Timer(const Duration(milliseconds: 100), () {
    //   result = [];
    //   if (search != v) {
    //     search = v;
    //     if (v != null && v.isNotEmpty) {
    //       try {
    //         var date = DateFormat('dd.MM.yyyy').parse(v);
    //         var history = getIt<HistoryRep>().historyCache;
    //         for (var it in history) {
    //           if (it.date.year == date.year &&
    //               it.date.month == date.month &&
    //               it.date.day == date.day) {
    //             result.add(it);
    //           }
    //         }
    //       } catch (_) {}
    //     }
    //     notifyListeners();
    //   }
    // });
  }
}
