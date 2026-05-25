import 'package:flutter_demo/features/history/domain/entities/history_root.dart';

class HistoryState {
  HistoryState({
    required this.list,
    this.startTime,
    this.startTimeString,
    this.endTime,
    this.endTimeString,
  });
  final List<HistoryRoot> list;
  final DateTime? startTime;
  final String? startTimeString;
  final DateTime? endTime;
  final String? endTimeString;
}
