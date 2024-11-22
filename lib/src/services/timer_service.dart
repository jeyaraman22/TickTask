import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class TimerService {
  static const String _timerKey = 'task_timers';
  static const String _activeTimersKey = 'active_timers';

// Singleton pattern
  static final TimerService instance = TimerService._internal();
  factory TimerService() => instance;
  TimerService._internal();

  final _timerController = StreamController<TimerUpdate>.broadcast();
  Stream<TimerUpdate> get timerUpdates => _timerController.stream;

  // Keep track of active timers in memory
  final Map<String, Timer> _activeTimers = {};
  final Map<String, Duration> _timeSpent = {};
  final Map<String, Duration> _elapsedTimes = {};
  final Map<String, DateTime> _startTimes = {};

  void startTimer(String taskId) {
    if (_activeTimers.containsKey(taskId)) return;

    final timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _timeSpent[taskId] =
          (_timeSpent[taskId] ?? Duration.zero) + const Duration(seconds: 1);
      _timerController.add(TimerUpdate(
        taskId: taskId,
        timeSpent: _timeSpent[taskId]!,
        isRunning: true,
      ));
      saveTaskTimer(taskId, _timeSpent[taskId]!, isRunning: true);
    });

    _activeTimers[taskId] = timer;
  }

  void stopTimer(String taskId) {
    _activeTimers[taskId]?.cancel();
    _activeTimers.remove(taskId);
    saveTaskTimer(taskId, _timeSpent[taskId] ?? Duration.zero,
        isRunning: false);
    _timerController.add(TimerUpdate(
      taskId: taskId,
      timeSpent: _timeSpent[taskId] ?? Duration.zero,
      isRunning: false,
    ));
  }

  bool isTimerRunning(String taskId) {
    return _activeTimers.containsKey(taskId);
  }

  Duration getTimeSpent(String taskId) {
    return _timeSpent[taskId] ?? Duration.zero;
  }

  // Initialize timers from storage
  Future<void> initializeTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? timerData = prefs.getString(_timerKey);
    if (timerData != null) {
      final Map<String, dynamic> timers = json.decode(timerData);
      for (var entry in timers.entries) {
        _timeSpent[entry.key] = Duration(seconds: entry.value);
      }
    }

    // Check for active timers
    final String? activeTimerData = prefs.getString(_activeTimersKey);
    if (activeTimerData != null) {
      final Map<String, dynamic> activeTimers = json.decode(activeTimerData);
      for (var entry in activeTimers.entries) {
        startTimer(entry.key);
      }
    }
  }

  void updateTimer(String taskId, Duration timeSpent, bool isRunning) {
    _timerController.add(TimerUpdate(
      taskId: taskId,
      timeSpent: timeSpent,
      isRunning: isRunning,
    ));
  }

  void clearTimer(String taskId) {
    _timeSpent.remove(taskId);
    _elapsedTimes.remove(taskId);
    _startTimes.remove(taskId);
  }

  // Save timer for a task
  static Future<void> saveTaskTimer(String taskId, Duration timeSpent,
      {bool isRunning = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final timers = await _getTimers();
    final activeTimers = await _getActiveTimers();

    // Save the accumulated time
    timers[taskId] = timeSpent.inSeconds;
    await prefs.setString(_timerKey, json.encode(timers));

    // If timer is running, save the current timestamp
    if (isRunning) {
      activeTimers[taskId] = DateTime.now().millisecondsSinceEpoch;
      await prefs.setString(_activeTimersKey, json.encode(activeTimers));
    } else {
      activeTimers.remove(taskId);
      await prefs.setString(_activeTimersKey, json.encode(activeTimers));
    }
  }

  // Get timer for a task
  static Future<(Duration timeSpent, bool wasRunning)> getTaskTimer(
      String taskId) async {
    final timers = await _getTimers();
    final activeTimers = await _getActiveTimers();

    final baseSeconds = timers[taskId] ?? 0;
    final lastActiveTimestamp = activeTimers[taskId];

    if (lastActiveTimestamp != null) {
      // Calculate additional time that passed while the app was closed
      final now = DateTime.now().millisecondsSinceEpoch;
      final additionalSeconds = (now - lastActiveTimestamp) ~/ 1000;
      return (Duration(seconds: baseSeconds + additionalSeconds), true);
    }

    return (Duration(seconds: baseSeconds), false);
  }

  static Future<Duration> getCompletedTaskTimer(String taskId) async {
    final timers = await _getTimers();
    final seconds = timers[taskId] ?? 0;
    return Duration(seconds: seconds);
  }

  // Get all timers
  static Future<Map<String, int>> _getTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? timerData = prefs.getString(_timerKey);
    if (timerData != null) {
      return Map<String, int>.from(json.decode(timerData));
    }
    return {};
  }

  static Future<Map<String, int>> _getActiveTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? activeTimerData = prefs.getString(_activeTimersKey);
    if (activeTimerData != null) {
      return Map<String, int>.from(json.decode(activeTimerData));
    }
    return {};
  }

  Future<void> saveTimeSpent(String taskId, Duration timeSpent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('timer_$taskId', timeSpent.inSeconds);
  }

  bool isRunning(String taskId) {
    return _activeTimers.containsKey(taskId) &&
        _activeTimers[taskId]?.isActive == true;
  }

  Duration getElapsedTime(String taskId) {
    if (!_elapsedTimes.containsKey(taskId)) return Duration.zero;

    if (isRunning(taskId)) {
      final now = DateTime.now();
      final startTime = _startTimes[taskId] ?? now;
      return _elapsedTimes[taskId]! + now.difference(startTime);
    }

    return _elapsedTimes[taskId]!;
  }

  void restoreTimer(String taskId, Duration elapsedTime) {
    if (isRunning(taskId)) {
      _elapsedTimes[taskId] = elapsedTime;
      _startTimes[taskId] = DateTime.now();
    }
  }
}

class TimerUpdate {
  final String taskId;
  final Duration timeSpent;
  final bool isRunning;

  TimerUpdate({
    required this.taskId,
    required this.timeSpent,
    required this.isRunning,
  });
}
