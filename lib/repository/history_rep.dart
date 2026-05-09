import 'dart:async';
import 'dart:io';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/semaphore.dart';
import 'package:flutter_demo/utils/common.dart';
import 'package:flutter_demo/utils/file_utils.dart';
import 'package:jiffy/jiffy.dart';
import 'package:loggy/loggy.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:collection/collection.dart';

class HistoryRecord with ChangeNotifier {
  HistoryRecord({
    required this.date,
    required this.dateHeader,
    required this.dateSub,
    required this.dateMonth,
    required this.items,
    required this.path,
    required this.folderName,
  });
  DateTime date;
  String dateHeader;
  String dateSub;
  String dateMonth;
  String folderName;
  String path;
  List<HistoryRecord> items;
  bool get selection => _selection;
  set selection(bool v) {
    _selection = v;
    notifyListeners();
  }

  bool _selection = false;
}

class HistoryRep {
  final onHistory = BehaviorSubject<List<HistoryRecord>>();
  final onHistoryDataSize = BehaviorSubject<Int64>.seeded(Int64.ZERO);
  var historyCache = <HistoryRecord>[];
  var _inited = false;
  final _historySemphore = Semaphore(1);
  final tag = 'historyRep';

  void init() {
    if (_inited) return;
    _inited = true;
  }

  void dispose() {}

  Future<List<HistoryRecord>> getHistory() async {
    await _historySemphore.acquire();
    historyCache = [];
    var dataSize = Int64();
    var path = Utils().galleryPath();
    // TODO: gallery use metadata
    try {
      var dir = Directory(path);
      var folders = await dir.list().toList();
      var mapByYear = <int, Map<int, List<HistoryRecord>>>{};
      var allFiles = <FileSystemEntity>[];
      for (var folder in folders) {
        var files = Directory(folder.path).listSync();
        allFiles.addAll(files);
        for (var file in files) {
          var name = Utils.getFileName(file.path);
          var date = Common().parseFileNameToDate(name);
          var dayOfYear = Jiffy.parseFromDateTime(date).dayOfYear;
          if (mapByYear[date.year] == null) {
            mapByYear[date.year] = <int, List<HistoryRecord>>{};
          }
          mapByYear[date.year]?[dayOfYear] = [];
        }
      }
      var now = DateTime.now();
      for (var file in allFiles) {
        var name = Utils.getFileName(file.path);
        var date = Common().parseFileNameToDate(name);
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
        var folderName = file.parent.path;
        dataSize += (await file.stat()).size;
        mapByYear[date.year]?[dateJiffy.dayOfYear]?.add(HistoryRecord(
            date: date,
            dateHeader: header,
            dateSub: sub,
            dateMonth: Common().monthString(date.month),
            folderName: folderName,
            items: [],
            path: file.path));
      }
      mapByYear.forEach((key, valueYear) {
        valueYear.forEach((key, valueDayOfYear) {
          valueDayOfYear.sort((a, b) {
            return a.date.compareTo(b.date);
          });
          var item = valueDayOfYear.first;
          var folderName = File(item.path).parent.path;
          historyCache.add(HistoryRecord(
              date: valueDayOfYear.first.date,
              dateHeader: item.dateHeader,
              dateSub: item.dateSub,
              dateMonth: item.dateMonth,
              folderName: folderName,
              items: valueDayOfYear,
              path: item.path));
        });
      });
      historyCache.sort((a, b) {
        return b.date.compareTo(a.date);
      });
    } catch (ex) {
      logWarning('$tag: ex');
    }
    onHistory.add(historyCache);
    onHistoryDataSize.add(dataSize);
    _historySemphore.release();
    return historyCache;
  }

  Future<void> deleteHistoryRoot(List<HistoryRecord> list) async {
    var removeItems = <HistoryRecord>[];
    for (var it in list) {
      for (var it2 in it.items) {
        try {
          removeItems.add(it2);
        } catch (ex) {
          logWarning('$tag: delete [$ex]');
        }
      }
    }
    for (var it in removeItems) {
      // get root item in cache
      var cacheItem = historyCache.firstWhereOrNull((h1) {
        return h1.folderName == it.folderName;
      });
      cacheItem?.items.removeWhere((element) {
        return element.path == it.path;
      });
      await File(it.path).delete();
    }
    historyCache.removeWhere((element) {
      return element.items.isEmpty;
    });
    onHistory.add(historyCache);
  }

  Future<void> deleteHistory(List<HistoryRecord> list) async {
    if (list.isEmpty) return;
    for (var it in list) {
      var v = historyCache.firstWhereOrNull((element) {
        return element.folderName == it.folderName;
      });
      try {
        await File(it.path).delete();
        v?.items.removeWhere((element) {
          return element.path == it.path;
        });
      } catch (ex) {
        logWarning('$tag: delete [$ex]');
      }
    }
    onHistory.add(historyCache);
  }

  void share(List<HistoryRecord> list) {
    if (list.isEmpty) return;
    var listPath = <XFile>[];
    for (var it in list) {
      listPath.add(XFile(it.path));
    }
    Share.shareXFiles(listPath, text: 'Check out this image!');
  }

  Future<void> freeData() async {
    await deleteHistoryRoot(historyCache);
    onHistoryDataSize.add(Int64.ZERO);
  }
}
