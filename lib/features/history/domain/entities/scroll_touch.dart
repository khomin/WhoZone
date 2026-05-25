import 'package:flutter/cupertino.dart';

class ScrollTouch with ChangeNotifier {
  final Set<int> touchPositions = {};
  var zoom = false;

  void savePointerPosition(int index) {
    touchPositions.add(index);
    notifyListeners();
  }

  void clearPointerPosition(int index) {
    touchPositions.remove(index);
    notifyListeners();
  }

  void setZoom(bool v) {
    if (zoom != v) {
      zoom = v;
      notifyListeners();
    }
  }
}
