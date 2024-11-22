abstract class TranslationKeys {
  final String key;
  TranslationKeys({required this.key});
}

class AppTranslationStrings extends TranslationKeys {
  AppTranslationStrings._internal({required super.key});

  // App General
  static final AppTranslationStrings appTitle =
      AppTranslationStrings._internal(key: "appTitle");

  // Settings
  static final AppTranslationStrings settings =
      AppTranslationStrings._internal(key: "settings");
  static final AppTranslationStrings theme =
      AppTranslationStrings._internal(key: "theme");
  static final AppTranslationStrings language =
      AppTranslationStrings._internal(key: "language");

  // Task Creation
  static final AppTranslationStrings createNewTask =
      AppTranslationStrings._internal(key: "createNewTask");
  static final AppTranslationStrings title =
      AppTranslationStrings._internal(key: "title");
  static final AppTranslationStrings titleRequired =
      AppTranslationStrings._internal(key: "titleRequired");
  static final AppTranslationStrings description =
      AppTranslationStrings._internal(key: "description");
  static final AppTranslationStrings descriptionOptional =
      AppTranslationStrings._internal(key: "descriptionOptional");
  static final AppTranslationStrings priority =
      AppTranslationStrings._internal(key: "priority");
  static final AppTranslationStrings labels =
      AppTranslationStrings._internal(key: "labels");
  static final AppTranslationStrings labelsOptional =
      AppTranslationStrings._internal(key: "labelsOptional");
  static final AppTranslationStrings labelsHint =
      AppTranslationStrings._internal(key: "labelsHint");
  static final AppTranslationStrings dueDate =
      AppTranslationStrings._internal(key: "dueDate");
  static final AppTranslationStrings category =
      AppTranslationStrings._internal(key: "category");
  static final AppTranslationStrings createTask =
      AppTranslationStrings._internal(key: "createTask");
  static final AppTranslationStrings addTask =
      AppTranslationStrings._internal(key: "addTask");
  static final AppTranslationStrings date =
      AppTranslationStrings._internal(key: "date");

  // Task Categories
  static final AppTranslationStrings todo =
      AppTranslationStrings._internal(key: "todo");
  static final AppTranslationStrings inProgress =
      AppTranslationStrings._internal(key: "inProgress");
  static final AppTranslationStrings done =
      AppTranslationStrings._internal(key: "done");

  // Task Details
  static final AppTranslationStrings taskDetails =
      AppTranslationStrings._internal(key: "taskDetails");
  static final AppTranslationStrings timeTracker =
      AppTranslationStrings._internal(key: "timeTracker");
  static final AppTranslationStrings startedAt =
      AppTranslationStrings._internal(key: "startedAt");
  static final AppTranslationStrings start =
      AppTranslationStrings._internal(key: "start");
  static final AppTranslationStrings pause =
      AppTranslationStrings._internal(key: "pause");
  static final AppTranslationStrings totalTimeSpent =
      AppTranslationStrings._internal(key: "totalTimeSpent");
  static final AppTranslationStrings changeDate =
      AppTranslationStrings._internal(key: "changeDate");

  // Comments
  static final AppTranslationStrings comments =
      AppTranslationStrings._internal(key: "comments");
  static final AppTranslationStrings addComment =
      AppTranslationStrings._internal(key: "addComment");
  static final AppTranslationStrings noCommentsYet =
      AppTranslationStrings._internal(key: "noCommentsYet");

  // Completed Tasks
  static final AppTranslationStrings noCompletedTasks =
      AppTranslationStrings._internal(key: "noCompletedTasks");
  static final AppTranslationStrings completedTasksHint =
      AppTranslationStrings._internal(key: "completedTasksHint");
  static final AppTranslationStrings completedTasks =
      AppTranslationStrings._internal(key: "completedTasks");
  static final AppTranslationStrings timeSpent =
      AppTranslationStrings._internal(key: "timeSpent");
  static final AppTranslationStrings completed =
      AppTranslationStrings._internal(key: "completed");
  static final AppTranslationStrings completeTask =
      AppTranslationStrings._internal(key: "completeTask");

  // Delete Task
  static final AppTranslationStrings deleteTask =
      AppTranslationStrings._internal(key: "deleteTask");
  static final AppTranslationStrings deleteTaskConfirmation =
      AppTranslationStrings._internal(key: "deleteTaskConfirmation");
  static final AppTranslationStrings cancel =
      AppTranslationStrings._internal(key: "cancel");
  static final AppTranslationStrings delete =
      AppTranslationStrings._internal(key: "delete");
  static final AppTranslationStrings retry =
      AppTranslationStrings._internal(key: "retry");
}
