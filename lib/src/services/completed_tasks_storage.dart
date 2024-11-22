import 'dart:convert';

import 'package:tick_task/src/core/di/dependency.dart';
import 'package:tick_task/src/data/model/task_response.dart';
import 'package:tick_task/src/services/app_preferences_service.dart';

// Service for managing completed tasks in local storage
class CompletedTasksStorage {
  // Key for storing completed tasks list
  static const String _key = 'completed_tasks';

  // Save a newly completed task to storage
  Future<void> saveCompletedTask(TodoistTaskResponseData task) async {
    final prefs = SL.getIt<AppPreferencesService>().prefs;
    final tasks = await getCompletedTasks();

    // Add new task to the beginning of the list (newest first)
    tasks.insert(0, task);

    // Convert tasks to JSON and save to storage
    final tasksJson = tasks.map((t) => t.toJson()).toList();
    await prefs.setString(_key, json.encode(tasksJson));

    // Calculate and save the completion time
    var timeSpent = DateTime.now().subtract(task.timeSpent ?? Duration.zero);
    await saveTaskCompletionTime(
        task.id ?? '', DateTime.now().difference(timeSpent));
  }

  // Retrieve all completed tasks from storage
  Future<List<TodoistTaskResponseData>> getCompletedTasks() async {
    final prefs = SL.getIt<AppPreferencesService>().prefs;
    final tasksString = prefs.getString(_key);

    // Return empty list if no tasks found
    if (tasksString == null) return [];

    // Parse JSON and convert to task objects
    final tasksList = json.decode(tasksString) as List;
    return tasksList.map((t) => TodoistTaskResponseData.fromJson(t)).toList();
  }

  // Remove all completed tasks from storage
  Future<void> clearCompletedTasks() async {
    final prefs = SL.getIt<AppPreferencesService>().prefs;
    await prefs.remove(_key);
  }

  // Check if a specific task is marked as completed
  Future<bool> isTaskCompleted(String taskId) async {
    final completedTasks = await getCompletedTasks();
    return completedTasks.any((task) => task.id == taskId);
  }

  // Save the time taken to complete a task
  Future<void> saveTaskCompletionTime(String taskId, Duration duration) async {
    final prefs = SL.getIt<AppPreferencesService>().prefs;
    await prefs.setInt('task_time_$taskId', duration.inSeconds);
  }

  // Retrieve the completion time for a specific task
  Future<Duration?> getTaskCompletionTime(String taskId) async {
    final prefs = SL.getIt<AppPreferencesService>().prefs;
    final timeInSeconds = prefs.getInt('task_time_$taskId');
    return timeInSeconds != null ? Duration(seconds: timeInSeconds) : null;
  }
}
