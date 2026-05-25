import 'package:flutter_demo/features/history/domain/entities/history_record.dart';
import 'package:flutter_demo/features/history/domain/entities/history_root.dart';
import 'package:flutter_demo/features/history/domain/entities/history_state.dart';
import 'package:rxdart/rxdart.dart';

abstract class HistoryRepo {
  void init();
  void dispose() {}

  BehaviorSubject<HistoryState> get historyRootStream => throw 'Unimplemented';
  BehaviorSubject<int> get usedDiskStream => throw 'Unimplemented';

  Future<bool> isEmpty();
  Future<void> updateHistory({DateTime? startTime, DateTime? endTime});
  Future<void> deleteHistoryRoot(List<HistoryRoot> list);
  Future<void> deleteHistory(List<History> list);
  void share(List<History> list);
  Future<void> freeData();
}
