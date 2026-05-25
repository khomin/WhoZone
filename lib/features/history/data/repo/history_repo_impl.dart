import 'dart:io';
import 'package:flutter_demo/core/utils/common.dart';
import 'package:flutter_demo/core/utils/semaphore.dart';
import 'package:flutter_demo/features/history/domain/entities/history_record.dart';
import 'package:flutter_demo/features/history/domain/entities/history_root.dart';
import 'package:flutter_demo/features/history/domain/entities/history_state.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/utils/utils.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:loggy/loggy.dart';
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/repo/history_repo.dart';

@lazySingleton
class HistoryRepoImpl implements HistoryRepo {
  final _historyRootStream = BehaviorSubject<HistoryState>();
  final _usedDiskStream = BehaviorSubject<int>();
  final _mapHistory = <DateTime, HistoryRoot>{};
  final _historySemphore = Semaphore(1);
  var _inited = false;
  final tag = 'historyRep';

  @override
  void init() {
    if (_inited) return;
    _inited = true;
  }

  @override
  void dispose() {}

  @override
  BehaviorSubject<HistoryState> get historyRootStream => _historyRootStream;

  @override
  BehaviorSubject<int> get usedDiskStream => throw _usedDiskStream;

  @override
  Future<bool> isEmpty() async {
    var path = Utils().historyPath();
    try {
      var dir = Directory(path);
      if (await dir.exists()) {
        var directories = await dir.list().toList();
        for (var it in directories) {
          var files = Directory(it.path).listSync();
          if (files.isNotEmpty) {
            return false;
          }
        }
      }
    } catch (ex) {
      logWarning('$tag: ex $ex');
    }
    return true;
  }

  @override
  Future<void> updateHistory({DateTime? startTime, DateTime? endTime}) async {
    await _historySemphore.acquire();
    _mapHistory.clear();
    var size = 0;
    var path = Utils().historyPath();
    try {
      var dir = Directory(path);
      if (await dir.exists()) {
        var directories = await dir.list().toList();
        var now = DateTime.now();
        for (var dir in directories) {
          var dirName = basename(dir.path);
          var creationDate = Common().parseDate(basename(dirName));
          var files = Directory(dir.path).listSync();
          if (files.isEmpty) {
            continue;
          }
          var items = <History>[];
          for (var file in files) {
            var record = _record(dir, file, now);
            if (startTime != null && record.date.isBefore(startTime)) {
              continue;
            }
            if (endTime != null) {
              if (record.date.isAfter(endTime)) {
                continue;
              }
            }
            items.add(record);
            size += (await file.stat()).size;
          }
          if (items.isEmpty) continue;
          var root = _recordRoot(
            dir: dir,
            file: files.first,
            now: now,
            items: items,
            fileCount: files.length,
            diskSpace: (await dir.stat()).size,
          );
          _mapHistory[creationDate] = root;
        }
      }
    } catch (ex) {
      logWarning('$tag: ex $ex');
    }
    // root
    var list = _mapHistory.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    _historyRootStream.add(HistoryState(
      list: list,
      startTime: startTime,
      startTimeString:
          startTime != null ? DateFormat('yyyy-MM-dd').format(startTime) : null,
      endTimeString:
          endTime != null ? DateFormat('yyyy-MM-dd').format(endTime) : null,
      endTime: endTime,
    ));
    // size
    _usedDiskStream.add(size);
    _historySemphore.release();
  }

  @override
  Future<void> deleteHistoryRoot(List<HistoryRoot> list) async {
    for (var it in list) {
      var r = _mapHistory.remove(it.date);
      if (r != null) {
        for (var it in r.items) {
          await File(it.path).delete();
        }
        var file = File(it.path);
        await file.parent.delete(recursive: true);
      }
    }
    updateHistory();
  }

  @override
  Future<void> deleteHistory(List<History> list) async {
    for (var it in list) {
      try {
        var file = File(it.path);
        await file.delete();
        var files = await file.parent.listSync();
        if (files.isEmpty) {
          await file.parent.delete(recursive: true);
        }
      } catch (ex) {
        logWarning('$tag: delete [$ex]');
      }
    }
    updateHistory();
  }

  @override
  void share(List<History> list) {
    if (list.isEmpty) return;
    var listPath = <XFile>[];
    for (var it in list) {
      listPath.add(XFile(it.path));
    }
    Share.shareXFiles(listPath, text: 'Check out this image!');
  }

  @override
  Future<void> freeData() async {
    var root = _mapHistory.values.toList();
    await deleteHistoryRoot(root);
    updateHistory();
  }

  HistoryRoot _recordRoot({
    required FileSystemEntity dir,
    required FileSystemEntity file,
    required DateTime now,
    required List<History> items,
    required int fileCount,
    required int diskSpace,
  }) {
    var path = basename(file.parent.path);
    var date = Common().parseDate(path);
    String header = '';
    String sub = '';
    var dateJiffy = Jiffy.parseFromDateTime(date);
    var jiffyNow = Jiffy.parseFromDateTime(now);
    // same year & month & day:
    if (dateJiffy.year == jiffyNow.year &&
        dateJiffy.dayOfYear == jiffyNow.dayOfYear) {
      header = Common().dayOfWeekString(dateJiffy.dayOfWeek);
      sub = 'Today';
    } else if (dateJiffy.year == jiffyNow.year &&
        dateJiffy.month == jiffyNow.month) {
      // same year & month:
      header = Common().dayOfWeekString(dateJiffy.dayOfWeek);
      var dayAgo = jiffyNow.dateTime.day - date.day;
      sub = dayAgo == 1 ? '$dayAgo day ago' : '$dayAgo days ago';
    } else {
      // other year:
      header = Common().dayOfWeekString(dateJiffy.dayOfWeek);
      sub = dateJiffy.year.toString();
    }
    return HistoryRoot(
      date: date,
      dateHeader: header,
      dateSub: sub,
      dateMonth: Common().monthString(date.month),
      folderName: dir.path,
      path: file.path,
      framesCount: fileCount,
      diskSpace: diskSpace,
      items: items,
    );
  }

  History _record(
    FileSystemEntity dir,
    FileSystemEntity file,
    DateTime now,
  ) {
    var name = Utils.getFileName(file.path);
    var date = DateTime.fromMicrosecondsSinceEpoch(
        int.parse(name.replaceAll(Constants.frameFileExtension, '')));
    String header = '';
    var dateJiffy = Jiffy.parseFromDateTime(date);
    var jiffyNow = Jiffy.parseFromDateTime(now);
    // same year & month & day:
    if (dateJiffy.year == jiffyNow.year &&
        dateJiffy.dayOfYear == jiffyNow.dayOfYear) {
      header = Common().dayOfWeekString(dateJiffy.dayOfWeek);
    } else if (dateJiffy.year == jiffyNow.year &&
        dateJiffy.month == jiffyNow.month) {
      // same year & month:
      header = Common().dayOfWeekString(dateJiffy.dayOfWeek);
    } else {
      // other year:
      header = Common().dayOfWeekString(dateJiffy.dayOfWeek);
    }
    return History(date: date, dateHeader: header, path: file.path);
  }
}
