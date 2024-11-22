part of 'task_detail_bloc.dart';

// Base state class for task detail states
abstract class TaskDetailState extends Equatable {
  const TaskDetailState();

  @override
  List<Object?> get props => [];
}

// Initial state when task detail page is first loaded
class TaskDetailInitial extends TaskDetailState {}

// State while task details are being loaded
class TaskDetailLoading extends TaskDetailState {}

// State when an error occurs during task detail operations
class TaskDetailError extends TaskDetailState {
  final String message;

  const TaskDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}

// State while comment actions (add/edit/delete) are in progress
class CommentActionInProgress extends TaskDetailState {}

// State when a comment action fails
class CommentActionFailure extends TaskDetailState {
  final String error;

  const CommentActionFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// State while task update is in progress
class TaskUpdateInProgress extends TaskDetailState {}

// State when task update is successful
class TaskUpdateSuccess extends TaskDetailState {}

// State when task update fails
class TaskUpdateFailure extends TaskDetailState {
  final String error;

  const TaskUpdateFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// State when task details are successfully loaded
class TaskDetailLoaded extends TaskDetailState {
  // Task and comment data
  final TodoistTaskResponseData task;
  final List<CommentsResponse> comments;

  // Timer related properties
  final Duration timeSpent;
  final bool isTimerRunning;
  final DateTime? startTime;
  final String elapsedTime;

  // State flags
  final bool isInitial;
  final bool isCompleted;

  TaskDetailLoaded({
    required this.task,
    required this.comments,
    required this.timeSpent,
    this.isTimerRunning = false,
    this.startTime,
    this.elapsedTime = '00:00:00',
    this.isInitial = false,
    this.isCompleted = false,
  });

  // Helper method to create a new instance with updated properties
  TaskDetailLoaded copyWith({
    TodoistTaskResponseData? task,
    List<CommentsResponse>? comments,
    Duration? timeSpent,
    bool? isTimerRunning,
    DateTime? startTime,
    String? elapsedTime,
    bool? isInitial,
    bool? isCompleted,
  }) {
    return TaskDetailLoaded(
      task: task ?? this.task,
      comments: comments ?? this.comments,
      timeSpent: timeSpent ?? this.timeSpent,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      startTime: startTime ?? this.startTime,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isInitial: isInitial ?? this.isInitial,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props =>
      [task, comments, timeSpent, isTimerRunning, startTime, elapsedTime];
}
