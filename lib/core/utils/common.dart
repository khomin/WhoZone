import 'package:flutter/material.dart';
import 'package:flutter_demo/components/message.dart';
import 'package:flutter_demo/core/repository/app_theme.dart';
import 'package:flutter_demo/core/repository/constants.dart';
import 'package:intl/intl.dart';

enum ToastType { normal, error }

extension DurationFormat on Duration {
  String format() => '$this'.split('.')[0].padLeft(8, '0');
}

class Common {
  DateTime parseDate(String name) {
    try {
      return DateFormat(Constants.recordDateFormat).parse(name);
    } catch (_) {}
    return DateTime(0);
  }

  static void showTextSnackBar({
    required BuildContext context,
    required String text,
    ToastType type = ToastType.normal,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: BottomMessage(type: type, text: text, animated: false),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.snackColor,
      ),
    );
  }

  String dayOfWeekString(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
    }
    return 'Unknown';
  }

  String monthString(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
    }
    return 'Unknown';
  }
}
