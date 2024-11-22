import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tick_task/l10n/helper/translation_keys.dart';

// A service class to handle all localization-related operations
class LocalizationService {
  final BuildContext context;

  LocalizationService(this.context);

  // Get localized string, returns key if translation is missing
  String get(TranslationKeys translationKey) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return translationKey.key;

    return _getTranslation(localizations, translationKey.key);
  }

  String _getTranslation(AppLocalizations localizations, String key) {
    switch (key) {
      // App General
      case 'appTitle':
        return localizations.appTitle;

      // Settings
      case 'theme':
        return localizations.theme;
      case 'language':
        return localizations.language;

      // Task Creation
      case 'createNewTask':
        return localizations.createNewTask;
      case 'title':
        return localizations.title;
      case 'titleRequired':
        return localizations.titleRequired;
      case 'description':
        return localizations.description;
      case 'descriptionOptional':
        return localizations.descriptionOptional;
      case 'priority':
        return localizations.priority;
      case 'labels':
        return localizations.labels;
      case 'labelsOptional':
        return localizations.labelsOptional;
      case 'labelsHint':
        return localizations.labelsHint;
      case 'dueDate':
        return localizations.dueDate;
      case 'category':
        return localizations.category;
      case 'createTask':
        return localizations.createTask;
      case 'date':
        return localizations.date;
      case 'addTask':
        return localizations.addTask;

      // Task Categories
      case 'todo':
        return localizations.todo;
      case 'inProgress':
        return localizations.inProgress;
      case 'done':
        return localizations.done;

      // Task Details
      case 'taskDetails':
        return localizations.taskDetails;
      case 'timeTracker':
        return localizations.timeTracker;
      case 'start':
        return localizations.start;
      case 'pause':
        return localizations.pause;
      case 'totalTimeSpent':
        return localizations.totalTimeSpent;
      case 'changeDate':
        return localizations.changeDate;

      case 'addComment':
        return localizations.addComment;
      case 'noCommentsYet':
        return localizations.noCommentsYet;

      // Completed Tasks
      case 'noCompletedTasks':
        return localizations.noCompletedTasks;
      case 'completedTasksHint':
        return localizations.completedTasksHint;
      case 'timeSpent':
        return localizations.timeSpent;
      case 'completed':
        return localizations.completed;
      case 'completeTask':
        return localizations.completeTask;
      case 'retry':
        return localizations.retry;

      default:
        return key;
    }
  }

  // Check if current locale is supported
  bool isLocaleSupported(String languageCode) {
    return Localizations.localeOf(context).languageCode == languageCode;
  }

  // Get current locale
  String get currentLocale => Localizations.localeOf(context).languageCode;

  // Check if the app is in English
  bool get isEnglish => currentLocale == 'en';

  // Check if the app is in German
  bool get isGerman => currentLocale == 'de';
}

// Extension for easy access through BuildContext
extension LocalizationX on BuildContext {
  LocalizationService get l10n => LocalizationService(this);
}
