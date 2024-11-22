import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tick_task/src/core/bloc/loader_mixin.dart';
import 'package:tick_task/src/core/rest_api/rest_api.dart';
import 'package:tick_task/src/core/rest_api/rest_api_endpoint.dart';
import 'package:tick_task/src/core/routes/router.dart';
import 'package:tick_task/src/data/repository/comments_repository.dart';
import 'package:tick_task/src/data/repository/task_repository.dart';
import 'package:tick_task/src/services/timer_service.dart';
import 'package:tick_task/src/services/completed_tasks_storage.dart';
import '../../../data/model/task_response.dart';
import '../../../data/model/comments_response.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

part 'task_detail_event.dart';
part 'task_detail_state.dart';

// Main BLoC for handling task details and related operations
class TaskDetailBloc extends Bloc<TaskDetailEvent, TaskDetailState>
    with LoaderMixin {
  // Dependencies and services
  final TaskRepository taskRepository;
  final CommentsRepository commentsRepository;
  final CompletedTasksStorage completedTasksStorage;
  TimerService timerService = TimerService();

  // Timer-related variables
  Timer? _timer;
  DateTime? _startTime;
  Duration _timeSpent = Duration.zero;
  StreamSubscription? _timerSubscription;

  // Constructor with dependency injection
  TaskDetailBloc({
    required this.taskRepository,
    required this.commentsRepository,
    required this.timerService,
    required this.completedTasksStorage,
  }) : super(TaskDetailInitial()) {
    // Register event handlers
    on<LoadTaskAndComments>(_onLoadTaskAndComments);
    on<AddComment>(_onAddComment);
    on<DeleteComment>(_onDeleteComment);
    on<UpdateComment>(_onUpdateComment);
    on<UpdateTask>(_onUpdateTask);
    on<PauseTimer>(_onPauseTimer);
    on<UpdateTimerTick>(_onUpdateTimerTick);
    on<ResetState>(_onResetState);
    on<StartTimer>(_onStartTimer);
    on<StopTimer>(_onStopTimer);
    on<UpdateTimeSpent>(_onUpdateTimeSpent);
    on<CompleteTask>(_onCompleteTask);
  }

  // Load task details and comments from API
  Future<void> _onLoadTaskAndComments(
    LoadTaskAndComments event,
    Emitter<TaskDetailState> emit,
  ) async {
    try {
      showLoader();

      final results = await Future.wait([
        taskRepository.getTaskById(
            RestApi(endPoint: AppEndPoint.getTaskUrl), event.taskId),
        commentsRepository.getComments(
            RestApi(endPoint: AppEndPoint.getCommentsUrl), event.taskId),
      ]);

      final task = results[0].data as TodoistTaskResponseData;
      final comments = results[1].data as List<CommentsResponse>;

      // Get the timer state from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedSeconds = prefs.getInt('task_timer_${event.taskId}') ?? 0;
      final isRunning =
          prefs.getBool('task_timer_running_${event.taskId}') ?? false;
      final startTimeStr = prefs.getString('task_timer_start_${event.taskId}');

      Duration timeSpent = Duration(seconds: savedSeconds);

      // Calculate elapsed time if timer was running
      if (isRunning && startTimeStr != null) {
        final startTime = DateTime.parse(startTimeStr);
        final elapsedSinceStart = DateTime.now().difference(startTime);
        timeSpent += elapsedSinceStart;
      }

      emit(TaskDetailLoaded(
          task: task,
          comments: comments,
          timeSpent: timeSpent,
          isTimerRunning: isRunning,
          isInitial: true));

      // Start updating the timer if it's running
      if (isRunning) {
        _startTimerUpdates(event.taskId);
      }
    } catch (e) {
      emit(TaskDetailError(message: e.toString()));
    } finally {
      hideLoader();
    }
  }

  // Start periodic timer updates
  void _startTimerUpdates(String taskId) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (state is TaskDetailLoaded) {
        final currentState = state as TaskDetailLoaded;
        final prefs = await SharedPreferences.getInstance();
        final savedSeconds = prefs.getInt('task_timer_${taskId}') ?? 0;
        final startTimeStr = prefs.getString('task_timer_start_${taskId}');

        if (startTimeStr != null) {
          final startTime = DateTime.parse(startTimeStr);
          final elapsed = DateTime.now().difference(startTime);
          final totalTime = Duration(seconds: savedSeconds) + elapsed;

          add(UpdateTimeSpent(totalTime));
        }
      }
    });
  }

  // Add new comment to task
  Future<void> _onAddComment(
    AddComment event,
    Emitter<TaskDetailState> emit,
  ) async {
    if (state is TaskDetailLoaded) {
      try {
        showLoader();

        final postedComment = await commentsRepository.addComments(
          RestApi(endPoint: AppEndPoint.createCommentsUrl),
          {
            'task_id': event.taskId,
            'content': event.content,
          },
        );

        final currentState = state as TaskDetailLoaded;
        emit(TaskDetailLoaded(
          task: currentState.task,
          comments: [...currentState.comments, postedComment.data!],
          timeSpent: currentState.timeSpent,
          isTimerRunning: currentState.isTimerRunning,
          startTime: currentState.startTime,
          elapsedTime: currentState.elapsedTime,
        ));
      } catch (e) {
        emit(CommentActionFailure(e.toString()));
        emit(state); // Restore previous state
      } finally {
        hideLoader();
      }
    }
  }

  // Delete existing comment
  Future<void> _onDeleteComment(
    DeleteComment event,
    Emitter<TaskDetailState> emit,
  ) async {
    if (state is TaskDetailLoaded) {
      try {
        showLoader();

        await commentsRepository.deleteComments(
            RestApi(endPoint: AppEndPoint.deleteCommentsUrl), event.commentId);

        final currentState = state as TaskDetailLoaded;
        emit(TaskDetailLoaded(
          task: currentState.task,
          comments: currentState.comments
              .where((c) => c.id != event.commentId)
              .toList(),
          timeSpent: currentState.timeSpent,
          isTimerRunning: currentState.isTimerRunning,
          startTime: currentState.startTime,
          elapsedTime: currentState.elapsedTime,
        ));
      } catch (e) {
        emit(CommentActionFailure(e.toString()));
        emit(state); // Restore previous state
      } finally {
        hideLoader();
      }
    }
  }

  // Update existing comment content
  Future<void> _onUpdateComment(
    UpdateComment event,
    Emitter<TaskDetailState> emit,
  ) async {
    if (state is TaskDetailLoaded) {
      try {
        showLoader();

        await commentsRepository.updateComments(
          RestApi(endPoint: AppEndPoint.updateCommentsUrl),
          {
            'id': event.commentId,
            'content': event.newContent,
          },
        );

        final currentState = state as TaskDetailLoaded;
        final updatedComments = currentState.comments.map((comment) {
          if (comment.id == event.commentId) {
            return comment.copyWith(content: event.newContent);
          }
          return comment;
        }).toList();
        emit(TaskDetailLoaded(
          task: currentState.task,
          comments: updatedComments,
          timeSpent: currentState.timeSpent,
          isTimerRunning: currentState.isTimerRunning,
          startTime: currentState.startTime,
          elapsedTime: currentState.elapsedTime,
        ));
      } catch (e) {
        emit(CommentActionFailure(e.toString()));
        emit(state); // Restore previous state
      } finally {
        hideLoader();
      }
    }
  }

  // Update task details
  Future<void> _onUpdateTask(
    UpdateTask event,
    Emitter<TaskDetailState> emit,
  ) async {
    if (state is TaskDetailLoaded) {
      try {
        showLoader();
        final updatedTaskResponse = await taskRepository.updateTasks(
          RestApi(endPoint: AppEndPoint.updateTaskUrl),
          {
            'id': (state as TaskDetailLoaded).task.id,
            'content': event.title,
            'description': event.description,
            'priority': event.priority,
            'due_string': event.dueDate?.toIso8601String(),
          },
        );

        final currentState = state as TaskDetailLoaded;

        emit(TaskDetailLoaded(
          task: updatedTaskResponse.data!,
          comments: currentState.comments,
          timeSpent: currentState.timeSpent,
          isTimerRunning: currentState.isTimerRunning,
          startTime: currentState.startTime,
          elapsedTime: currentState.elapsedTime,
        ));
      } catch (e) {
        emit(TaskUpdateFailure(e.toString()));
        emit(state);
      } finally {
        hideLoader();
      }
    }
  }

  // Start task timer
  void _onStartTimer(
    StartTimer event,
    Emitter<TaskDetailState> emit,
  ) {
    if (state is TaskDetailLoaded) {
      final currentState = state as TaskDetailLoaded;
      _startTime = DateTime.now();

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!isClosed && state is TaskDetailLoaded) {
          final now = DateTime.now();
          final elapsed = now.difference(_startTime!);
          final totalTime = _timeSpent + elapsed;

          add(UpdateTimerTick(
            isTimerRunning: true,
            startTime: _startTime,
            timeSpent: totalTime,
            elapsedTime: _formatDuration(totalTime),
          ));
        }
      });

      // Notify TimerService about the timer start
      timerService.updateTimer(
        event.taskId,
        _timeSpent,
        true,
      );

      emit(currentState.copyWith(
        isTimerRunning: true,
        startTime: _startTime,
      ));
    }
  }

  // Pause running timer
  void _onPauseTimer(
    PauseTimer event,
    Emitter<TaskDetailState> emit,
  ) async {
    if (state is TaskDetailLoaded) {
      final currentState = state as TaskDetailLoaded;
      _timer?.cancel();

      if (_startTime != null) {
        final elapsed = DateTime.now().difference(_startTime!);
        _timeSpent += elapsed;

        // Save time spent to persistent storage
        await timerService.saveTimeSpent(event.taskId, _timeSpent);
      }

      emit(currentState.copyWith(
        isTimerRunning: false,
        startTime: null,
        timeSpent: _timeSpent,
        elapsedTime: _formatDuration(_timeSpent),
      ));
    }
  }

  // Update timer display on tick
  void _onUpdateTimerTick(
    UpdateTimerTick event,
    Emitter<TaskDetailState> emit,
  ) {
    if (state is TaskDetailLoaded) {
      final currentState = state as TaskDetailLoaded;

      // Notify TimerService about the timer update
      timerService.updateTimer(
        currentState.task.id ?? '',
        event.timeSpent,
        true,
      );

      emit(currentState.copyWith(
        isTimerRunning: event.isTimerRunning,
        startTime: event.startTime,
        timeSpent: event.timeSpent,
        elapsedTime: event.elapsedTime,
      ));
    }
  }

  // Reset bloc to initial state
  void _onResetState(ResetState event, Emitter<TaskDetailState> emit) {
    emit(TaskDetailInitial());
  }

  // Stop running timer
  void _onStopTimer(StopTimer event, Emitter<TaskDetailState> emit) {
    _timer?.cancel();
    if (state is TaskDetailLoaded) {
      final currentState = state as TaskDetailLoaded;
      emit(currentState.copyWith(isTimerRunning: false));
    }
  }

  // Update total time spent on task
  void _onUpdateTimeSpent(
      UpdateTimeSpent event, Emitter<TaskDetailState> emit) {
    if (state is TaskDetailLoaded) {
      final currentState = state as TaskDetailLoaded;
      emit(currentState.copyWith(timeSpent: event.timeSpent));
    }
  }

  // Mark task as complete
  Future<void> _onCompleteTask(
    CompleteTask event,
    Emitter<TaskDetailState> emit,
  ) async {
    if (state is TaskDetailLoaded) {
      try {
        showLoader();
        final updatedTask = await taskRepository.updateTasks(
          RestApi(endPoint: AppEndPoint.updateTaskUrl),
          event.task.toJson(),
        );

        updatedTask.data?.timeSpent = event.task.timeSpent;
        // Save to local storage
        await completedTasksStorage.saveCompletedTask(updatedTask.data!);

        final currentState = state as TaskDetailLoaded;
        emit(TaskDetailLoaded(
          task: updatedTask.data!,
          comments: currentState.comments,
          timeSpent: currentState.timeSpent,
          isTimerRunning: false,
          isInitial: false,
          isCompleted: true,
        ));

        AppRouter.router.pop();
      } catch (e) {
        emit(TaskDetailError(message: e.toString()));
      } finally {
        hideLoader();
      }
    }
  }

  // Format duration for display
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  // Clean up resources when bloc is closed
  @override
  Future<void> close() {
    _timer?.cancel();
    _timerSubscription?.cancel();
    return super.close();
  }
}
