import 'package:flutter/material.dart';
import 'package:flutter_demo/features/history/domain/entities/history_record.dart';

class HistoryRoot with ChangeNotifier {
  HistoryRoot({
    required this.date,
    required this.dateHeader,
    required this.dateSub,
    required this.dateMonth,
    required this.path,
    required this.folderName,
    required this.framesCount,
    required this.diskSpace,
    required this.items,
  });
  DateTime date;
  String dateHeader;
  String dateSub;
  String dateMonth;
  String folderName;
  String path;
  int framesCount;
  int diskSpace;
  List<History> items;
}
