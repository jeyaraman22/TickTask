import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tick_task/src/core/di/dependency.dart';
import 'package:tick_task/src/services/app_preferences_service.dart';

// Service for managing task labels in local storage
class TaskLabelStorage {
  // Key for storing task labels map
  static const String _key = 'task_labels';

  // Save labels for a specific task
  Future<void> saveTaskLabel(String taskId, List<String> labels) async {
    final prefs = SL.getIt<AppPreferencesService>().prefs;
    final labelsMap = await _getLabelsMap(prefs);

    // Update labels for the task
    labelsMap[taskId] = labels;
    await prefs.setString(_key, json.encode(labelsMap));
  }

  // Retrieve labels for a specific task
  Future<List<String>?> getTaskLabels(String taskId) async {
    final prefs = SL.getIt<AppPreferencesService>().prefs;
    final labelsMap = await _getLabelsMap(prefs);

    // Convert labels to List<String> if found
    final labels = labelsMap[taskId];
    if (labels != null) {
      return List<String>.from(labels);
    }
    return null;
  }

  // Helper method to get the labels map from storage
  Future<Map<String, dynamic>> _getLabelsMap(SharedPreferences prefs) async {
    final String? labelsString = prefs.getString(_key);
    if (labelsString != null) {
      return json.decode(labelsString) as Map<String, dynamic>;
    }
    return {};
  }

  // Remove labels for a specific task
  Future<void> clearTaskLabel(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final labelsMap = await _getLabelsMap(prefs);

    // Remove task entry from labels map
    labelsMap.remove(taskId);
    await prefs.setString(_key, json.encode(labelsMap));
  }
}
