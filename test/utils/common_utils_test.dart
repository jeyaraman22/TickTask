import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tick_task/src/core/utils/common_utils.dart';

void main() {
  group('CommonUtils Tests', () {
    test('getPriorityColor returns correct colors', () {
      expect(CommonUtils.getPriorityColor(4), Colors.red);
      expect(CommonUtils.getPriorityColor(3), Colors.amber);
      expect(CommonUtils.getPriorityColor(2), Colors.blue);
      expect(CommonUtils.getPriorityColor(1), Colors.grey);
      expect(CommonUtils.getPriorityColor(0), Colors.grey);
    });

    test('getPriority returns correct priority values', () {
      expect(CommonUtils.getPriority(1), 4);
      expect(CommonUtils.getPriority(2), 3);
      expect(CommonUtils.getPriority(3), 2);
      expect(CommonUtils.getPriority(4), 1);
      expect(CommonUtils.getPriority(null), 1);
    });

    test('formatDate returns correct date format', () {
      final date = DateTime(2024, 3, 15);
      expect(CommonUtils.formatDate(date), '2024-03-15');
    });
  });
}
