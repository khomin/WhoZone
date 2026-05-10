import 'dart:async';
import 'dart:io';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/semaphore.dart';
import 'package:flutter_demo/utils/common.dart';
import 'package:flutter_demo/utils/utils.dart';
import 'package:jiffy/jiffy.dart';
import 'package:loggy/loggy.dart';
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';

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
  });
  DateTime date;
  String dateHeader;
  String dateSub;
  String dateMonth;
  String folderName;
  String path;
  int framesCount;
  int diskSpace;
}

class History with ChangeNotifier {
  History({
    required this.date,
    required this.dateHeader,
    required this.path,
  });
  DateTime date;
  String dateHeader;
  String path;

  bool get selection => _selection;
  set selection(bool v) {
    _selection = v;
    notifyListeners();
  }

  bool _selection = false;
}

class HistoryRep {
  final onHistory = BehaviorSubject<List<HistoryRoot>>();
  final onHistorySize = BehaviorSubject<Int64>.seeded(Int64.ZERO);
  final _mapHistory = <HistoryRoot, List<History>>{};
  var _inited = false;
  final _historySemphore = Semaphore(1);
  final tag = 'historyRep';

  void init() {
    if (_inited) return;
    _inited = true;
  }

  void dispose() {}

  Future<bool> isEmpty() async {
    var path = Utils().historyPath();
    try {
      var dir = Directory(path);
      var directories = await dir.list().toList();
      return directories.isEmpty;
    } catch (ex) {
      logWarning('$tag: ex');
    }
    return true;
  }

  Future<void> updateHistory() async {
    await _historySemphore.acquire();
    // historyCache = [];
    _mapHistory.clear();
    var dataSize = Int64();
    var path = Utils().historyPath();
    // TODO: gallery use metadata
    try {
      var dir = Directory(path);
      var directories = await dir.list().toList();
      var now = DateTime.now();
      for (var dir in directories) {
        var files = Directory(dir.path).listSync();
        if (files.isEmpty) {
          continue;
        }
        var root = _recordRoot(
          dir: dir,
          file: files.first,
          now: now,
          fileCount: files.length,
          diskSpace: (await dir.stat()).size,
        );
        _mapHistory[root] = <History>[];
        var records = <History>[];
        for (var file in files) {
          root.framesCount++;
          records.add(_record(dir, file, now));
        }
        _mapHistory[root]?.addAll(records);
      }
    } catch (ex) {
      logWarning('$tag: ex');
    }
    var history = _mapHistory.keys.toList();
    history.sort((a, b) => b.date.compareTo(a.date));
    onHistory.add(history);
    onHistorySize.add(dataSize);
    _historySemphore.release();
  }

  Future<void> deleteHistoryRoot(List<HistoryRoot> list) async {
    // var removeItems = <HistoryRoot>[];
    // for (var it in list) {
    //   for (var it2 in it.items) {
    //     try {
    //       removeItems.add(it2);
    //     } catch (ex) {
    //       logWarning('$tag: delete [$ex]');
    //     }
    //   }
    // }
    // for (var it in removeItems) {
    //   // get root item in cache
    //   var cacheItem = historyCache.firstWhereOrNull((h1) {
    //     return h1.folderName == it.folderName;
    //   });
    //   cacheItem?.items.removeWhere((element) {
    //     return element.path == it.path;
    //   });
    //   await File(it.path).delete();
    // }
    // historyCache.removeWhere((element) {
    //   return element.items.isEmpty;
    // });
    // onHistory.add(historyCache);
  }

  Future<void> deleteHistory(List<History> list) async {
    // if (list.isEmpty) return;
    // for (var it in list) {
    //   var v = historyCache.firstWhereOrNull((element) {
    //     return element.folderName == it.folderName;
    //   });
    //   try {
    //     await File(it.path).delete();
    //     v?.items.removeWhere((element) {
    //       return element.path == it.path;
    //     });
    //   } catch (ex) {
    //     logWarning('$tag: delete [$ex]');
    //   }
    // }
    // onHistory.add(historyCache);
  }

  void share(List<History> list) {
    if (list.isEmpty) return;
    var listPath = <XFile>[];
    for (var it in list) {
      listPath.add(XFile(it.path));
    }
    Share.shareXFiles(listPath, text: 'Check out this image!');
  }

  Future<void> freeData() async {
    // await deleteHistoryRoot(historyCache);
    // onHistoryDataSize.add(Int64.ZERO);
  }

  HistoryRoot _recordRoot({
    required FileSystemEntity dir,
    required FileSystemEntity file,
    required DateTime now,
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
    );
  }

  History _record(
    FileSystemEntity dir,
    FileSystemEntity file,
    DateTime now,
  ) {
    var name = Utils.getFileName(file.path);
    var date = Common().parseDate(name);
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
