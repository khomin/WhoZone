import 'package:flutter/material.dart';

class History with ChangeNotifier {
  History({
    required this.date,
    required this.dateHeader,
    required this.path,
  });
  DateTime date;
  String dateHeader;
  String path;
}
