import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@injectable
class HistoryModel with ChangeNotifier {
  HistoryModel();

  bool ready = false;

  void setReady(bool v) {
    if (v != ready) {
      ready = v;
      notifyListeners();
    }
  }
}
