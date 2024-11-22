import 'package:flutter/material.dart';

class CommonUtils {
  // Private constructor to prevent instantiation
  CommonUtils._();

  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 4:
        return Colors.red;
      case 3:
        return Colors.amber;
      case 2:
        return Colors.blue;
      case 1:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  static num getPriority(int? priority) {
    switch (priority) {
      case 1:
        return 4;
      case 2:
        return 3;
      case 3:
        return 2;
      case 4:
        return 1;
      default:
        return 1;
    }
  }

  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$year-$month-$day';
  }
}
