// Custom class to represent a task
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tick_task/src/services/timer_service.dart';

class TaskItem {
  final String title;
  final String? id;
  final String? description;
  final int? priority;
  final List<String>? labels;
  final DateTime? dueDate;
  Duration timeSpent;
  bool isTimerRunning;
  Timer? timer;
  // Add a callback for UI updates
  VoidCallback? onTimerUpdate;
  // List<String> comments;
  int? commentCount;
  DateTime? createdAt;
  bool? isCompleted;

  static const String _timerPrefix = 'task_timer_';
  static const String _isRunningPrefix = 'task_timer_running_';
  static const String _startTimePrefix = 'task_timer_start_';

  TaskItem(
    this.title, {
    this.id,
    this.description,
    this.priority,
    this.labels,
    this.dueDate,
    this.timeSpent = const Duration(),
    this.isTimerRunning = false,
    // this.comments = const [],
    this.commentCount,
    this.createdAt,
    this.isCompleted,
  });

  // Convert TaskItem to JSON
  Map<String, dynamic> toJson() => {
        'content': title,
        'id': id,
        'description': description,
        'priority': priority,
        'labels': labels,
        'due_string': dueDate?.toIso8601String(),
        'timeSpent': timeSpent.inSeconds,
        'isTimerRunning': isTimerRunning,
        'commentCount': commentCount,
        'createdAt': createdAt?.toIso8601String(),
        'is_completed': isCompleted
      };

  // Create TaskItem from JSON
  factory TaskItem.fromJson(Map<String, dynamic> json) => TaskItem(
        json['content'],
        id: json['id'],
        description: json['description'],
        priority: json['priority'],
        labels: (json['labels'] as List<dynamic>?)
            ?.map((label) => label as String)
            .toList(),
        dueDate: json['dueDate'] != null
            ? DateTime.parse(json['dueDate'] as String)
            : null,
        timeSpent: Duration(seconds: json['timeSpent']),
        isTimerRunning: json['isTimerRunning'],
        commentCount: json['commentCount'],
        createdAt: DateTime.parse(json['createdAt']),
        isCompleted: json['is_completed'],
      );

  Future<void> initializeTimer() async {
    final (savedTime, wasRunning) = await TimerService.getTaskTimer(id ?? '0');
    timeSpent = savedTime;
    if (wasRunning) {
      startTimer();
    }
  }

  Future<void> loadSavedTimer() async {
    if (id == null) return;

    final prefs = await SharedPreferences.getInstance();
    final wasRunning = prefs.getBool('${_isRunningPrefix}${id}') ?? false;
    final savedSeconds = prefs.getInt('${_timerPrefix}${id}') ?? 0;
    final startTimeStr = prefs.getString('${_startTimePrefix}${id}');

    if (wasRunning && startTimeStr != null) {
      // Calculate elapsed time since last save
      final startTime = DateTime.parse(startTimeStr);
      final now = DateTime.now();
      final elapsedSinceLastSave = now.difference(startTime);

      // Add the elapsed time to the saved time
      timeSpent = Duration(seconds: savedSeconds) + elapsedSinceLastSave;
      startTimer(continueExisting: true);
    } else {
      timeSpent = Duration(seconds: savedSeconds);
    }
  }

  Future<void> saveTimerState() async {
    if (id == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_timerPrefix}${id}', timeSpent.inSeconds);
    await prefs.setBool('${_isRunningPrefix}${id}', isTimerRunning);

    if (isTimerRunning) {
      // Save the current timestamp
      await prefs.setString(
          '${_startTimePrefix}${id}', DateTime.now().toIso8601String());
    } else {
      // Clear the start time if timer is stopped
      await prefs.remove('${_startTimePrefix}${id}');
    }
  }

  void startTimer({bool continueExisting = false}) {
    if (!isTimerRunning) {
      isTimerRunning = true;
      if (!continueExisting) {
        // Save start time only if this is a new timer start
        saveTimerState();
      }

      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        timeSpent += const Duration(seconds: 1);
        onTimerUpdate?.call();
      });
    }
  }

  void stopTimer() {
    isTimerRunning = false;
    timer?.cancel();
    timer = null;
    saveTimerState();
  }

  Future<void> clearTimerData() async {
    if (id == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_timerPrefix}${id}');
    await prefs.remove('${_isRunningPrefix}${id}');
    await prefs.remove('${_startTimePrefix}${id}');
    timeSpent = Duration.zero;
    stopTimer();
  }
}

// Custom data class to track dragged item's details
class DragData {
  final TaskItem item;
  final List<TaskItem> sourceList;
  final int sourceIndex;
  Offset globalPosition;

  DragData(
      {required this.item,
      required this.sourceList,
      required this.sourceIndex,
      this.globalPosition = Offset.zero});
}
