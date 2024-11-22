part of 'task_detail_bloc.dart';

// Base class for all task detail events
abstract class TaskDetailEvent extends Equatable {
  const TaskDetailEvent();

  @override
  List<Object?> get props => [];
}

// Event to load task details and associated comments
class LoadTaskAndComments extends TaskDetailEvent {
  final String taskId;
  const LoadTaskAndComments(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

// Event to add a new comment to a task
class AddComment extends TaskDetailEvent {
  final String taskId;
  final String content;

  const AddComment({
    required this.taskId,
    required this.content,
  });

  @override
  List<Object?> get props => [taskId, content];
}

// Event to delete an existing comment
class DeleteComment extends TaskDetailEvent {
  final String commentId;
  final String taskId;

  const DeleteComment({
    required this.commentId,
    required this.taskId,
  });

  @override
  List<Object?> get props => [commentId, taskId];
}

// Event to update an existing comment's content
class UpdateComment extends TaskDetailEvent {
  final String commentId;
  final String taskId;
  final String newContent;

  const UpdateComment({
    required this.commentId,
    required this.taskId,
    required this.newContent,
  });

  @override
  List<Object?> get props => [commentId, taskId, newContent];
}

// Event to update task details (title, description, priority, due date)
class UpdateTask extends TaskDetailEvent {
  final String? title;
  final String? description;
  final int? priority;
  final DateTime? dueDate;

  const UpdateTask({
    this.title,
    this.description,
    this.priority,
    this.dueDate,
  });

  @override
  List<Object?> get props => [title, description, priority, dueDate];
}

// Event to start the task timer
class StartTimer extends TaskDetailEvent {
  final String taskId;

  const StartTimer(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

// Event to pause the running timer
class PauseTimer extends TaskDetailEvent {
  final String taskId;

  const PauseTimer(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

// Event to update timer display on each tick
class UpdateTimerTick extends TaskDetailEvent {
  final bool isTimerRunning;
  final DateTime? startTime;
  final Duration timeSpent;
  final String elapsedTime;

  const UpdateTimerTick({
    required this.isTimerRunning,
    required this.startTime,
    required this.timeSpent,
    required this.elapsedTime,
  });

  @override
  List<Object?> get props =>
      [isTimerRunning, startTime, timeSpent, elapsedTime];
}

// Event to reset bloc to initial state
class ResetState extends TaskDetailEvent {}

// Event to stop the running timer
class StopTimer extends TaskDetailEvent {
  final String taskId;

  const StopTimer(this.taskId);
}

// Event to update total time spent on task
class UpdateTimeSpent extends TaskDetailEvent {
  final Duration timeSpent;

  const UpdateTimeSpent(this.timeSpent);
}

// Event to mark task as complete
class CompleteTask extends TaskDetailEvent {
  final TodoistTaskResponseData task;

  const CompleteTask(this.task);

  @override
  List<Object?> get props => [task];
}
