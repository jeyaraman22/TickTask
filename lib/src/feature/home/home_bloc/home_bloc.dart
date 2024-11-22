import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tick_task/src/core/bloc/loader_mixin.dart';
import 'package:tick_task/src/core/rest_api/rest_api.dart';
import 'package:tick_task/src/core/rest_api/rest_api_endpoint.dart';
import 'package:tick_task/src/data/model/custom_task_data.dart';
import 'package:tick_task/src/feature/create_task/create_task_page.dart';

import '../../../core/di/dependency.dart';
import '../../../data/model/task_response.dart';
import '../../../data/repository/task_repository.dart';
import '../../../services/completed_tasks_storage.dart';
import '../../../services/timer_service.dart';
import '../../../services/task_label_storage.dart';

// Events - Define all possible actions that can trigger state changes
abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Event to fetch all tasks from the repository
class FetchTasks extends HomeEvent {
  final bool preserveTimerState;
  FetchTasks({this.preserveTimerState = false});
}

// Event to add a new task to the list
class AddTask extends HomeEvent {
  final TodoistTaskResponseData tasksResponse;
  AddTask(this.tasksResponse);
  @override
  List<Object?> get props => [tasksResponse];
}

// Event to update an existing task
class UpdateTask extends HomeEvent {
  final TodoistTaskResponseData tasksResponse;
  UpdateTask(this.tasksResponse);
  @override
  List<Object?> get props => [tasksResponse];
}

// Event to update task timer state
class UpdateTaskTimer extends HomeEvent {
  final String taskId;
  final Duration timeSpent;
  final bool isRunning;

  UpdateTaskTimer({
    required this.taskId,
    required this.timeSpent,
    required this.isRunning,
  });

  @override
  List<Object?> get props => [taskId, timeSpent, isRunning];
}

// Event to update task details
class UpdateTaskDetails extends HomeEvent {
  final TodoistTaskResponseData updatedTask;

  UpdateTaskDetails(this.updatedTask);

  @override
  List<Object?> get props => [updatedTask];
}

// Event to add a new task event
class AddTaskEvent extends HomeEvent {
  final TaskItem task;
  final TaskCategory category;

  AddTaskEvent(this.task, this.category);

  @override
  List<Object?> get props => [task, category];
}

// Event to complete a task
class CompleteTask extends HomeEvent {
  final TodoistTaskResponseData task;
  CompleteTask(this.task);

  @override
  List<Object?> get props => [task];
}

// Event to move to add task page
class MoveToAddTaskPage extends HomeEvent {}

// Event to move to task details
class MoveToTaskDetails extends HomeEvent {
  final String taskId;
  MoveToTaskDetails({required this.taskId});
}

// Event to delete a task
class DeleteTask extends HomeEvent {
  final TodoistTaskResponseData task;
  DeleteTask(this.task);

  @override
  List<Object?> get props => [task];
}

// Event to update home page
class HomeUpdateEvent extends HomeEvent {}

// Event to complete a task
class TaskCompleted extends HomeEvent {
  @override
  List<Object?> get props => [];
}

// Event to reset navigation state
class ResetNavigationState extends HomeEvent {
  @override
  List<Object?> get props => [];
}

// States - Define all possible UI states
abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial state when bloc is created
class HomeInitial extends HomeState {}

// State when tasks are successfully loaded
class HomeLoaded extends HomeState {
  final List<TodoistTaskResponseData> tasks;
  HomeLoaded(this.tasks);

  // Helper method to create new instance with updated tasks
  HomeLoaded copyWith({List<TodoistTaskResponseData>? tasks}) {
    return HomeLoaded(tasks ?? this.tasks);
  }

  @override
  List<Object?> get props => [tasks];
}

// State when there's an error
class HomeError extends HomeState {
  final String message;
  HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

// State when moving to task details
class MoveToTaskDetailsState extends HomeState {
  final String taskId;
  MoveToTaskDetailsState(this.taskId);
}

// State when moving to add task page
class MoveToAddTaskPageState extends HomeState {}

// State when home page is updated
class HomePageUpdateState extends HomeState {}

// State when a task is completed
class TaskCompletedState extends HomeState {
  @override
  List<Object?> get props => [];
}

// State when a task is updated
class TaskUpdatedState extends HomeState {}

// Main BLoC class to handle business logic
class HomeBloc extends Bloc<HomeEvent, HomeState> with LoaderMixin {
  final TaskRepository taskRepository;
  final TimerService timerService;
  final TaskLabelStorage labelStorage;
  late final StreamSubscription _timerSubscription;
  final Map<String, Duration> _timerStates = {};

  HomeBloc({
    required this.taskRepository,
    required this.timerService,
    required this.labelStorage,
  }) : super(HomeInitial()) {
    // Register event handlers
    on<FetchTasks>(_onFetchTasks);
    on<UpdateTask>(_onUpdateTask);
    on<UpdateTaskTimer>(_onUpdateTaskTimer);
    on<UpdateTaskDetails>(_onUpdateTaskDetails);
    on<AddTaskEvent>(_onAddTaskEvent);
    on<CompleteTask>(_onCompleteTask);
    on<MoveToTaskDetails>(_onMoveToTaskDetails);
    on<MoveToAddTaskPage>(_onMoveToAddTaskPage);
    on<DeleteTask>(_onDeleteTask);
    on<TaskCompleted>(_onTaskCompleted);
    on<ResetNavigationState>(_onResetNavigationState);

    // Listen to timer updates from TimerService
    _timerSubscription = timerService.timerUpdates.listen((update) {
      add(UpdateTaskTimer(
        taskId: update.taskId,
        timeSpent: update.timeSpent,
        isRunning: update.isRunning,
      ));
    });
  }

  // Handler for fetching tasks
  Future<void> _onFetchTasks(FetchTasks event, Emitter<HomeState> emit) async {
    try {
      showLoader();
      final tasks = await taskRepository
          .getTasks(RestApi(endPoint: AppEndPoint.getTaskUrl));

      // Preserve timer states if requested
      if (event.preserveTimerState) {
        // Store current timer states
        for (var task in tasks.data ?? []) {
          if (timerService.isRunning(task.id ?? '')) {
            _timerStates[task.id ?? ''] =
                timerService.getElapsedTime(task.id ?? '');
          }
        }

        // Restore timer states
        for (var task in tasks.data ?? []) {
          final storedTime = _timerStates[task.id];
          if (storedTime != null) {
            timerService.restoreTimer(task.id ?? '', storedTime);
          }
        }
      }

      final completedTaskStorage = SL.get<CompletedTasksStorage>();

      // Split tasks into active and completed
      final List<TodoistTaskResponseData> activeTasks = [];
      final List<TodoistTaskResponseData> completedTasks = [];

      for (var task in tasks.data ?? []) {
        final isCompletedLocally =
            await completedTaskStorage.isTaskCompleted(task.id ?? '');
        if (isCompletedLocally) {
          completedTasks.add(task);
        } else {
          activeTasks.add(task);
        }
      }

      // Get tasks with local labels
      final updatedTasks = await Future.wait((activeTasks).map((task) async {
        final localLabels = await labelStorage.getTaskLabels(task.id ?? '');
        if (localLabels != null) {
          return task.copyWith(labels: localLabels);
        }
        return task;
      }));

      emit(HomeLoaded(updatedTasks));
    } catch (e) {
      emit(HomeError(e.toString()));
    } finally {
      hideLoader();
    }
  }

  void _onUpdateTaskTimer(UpdateTaskTimer event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final updatedTasks =
          currentState.tasks.map<TodoistTaskResponseData>((task) {
        if (task.id == event.taskId) {
          return task.copyWith(
            timeSpent: event.timeSpent,
            isTimerRunning: event.isRunning,
          );
        }
        return task;
      }).toList();

      emit(HomeLoaded(updatedTasks));
    }
  }

  void _onUpdateTaskDetails(UpdateTaskDetails event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final updatedTasks =
          currentState.tasks.map<TodoistTaskResponseData>((task) {
        if (task.id == event.updatedTask.id) {
          return event.updatedTask;
        }
        return task;
      }).toList();

      emit(HomeLoaded(updatedTasks));
    }
  }

  void _onAddTaskEvent(AddTaskEvent event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final taskData = TodoistTaskResponseData(
        id: event.task.id,
        content: event.task.title,
        description: event.task.description,
        priority: event.task.priority,
        labels: event.task.labels,
        due: Due(date: event.task.dueDate?.toIso8601String()),
        isCompleted: false,
        timeSpent: Duration.zero,
        isTimerRunning: false,
        // Add any other required fields with appropriate default values
      );

      final updatedTasks = [...currentState.tasks, taskData];
      emit(HomeLoaded(updatedTasks));
    }
  }

  Future<void> _onCompleteTask(
      CompleteTask event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;

      // Update the task's completion status
      final updatedTask = event.task.copyWith(
        isCompleted: true,
        labels: [...(event.task.labels ?? []), 'Done'],
      );

      // Update the task in the list
      final updatedTasks = currentState.tasks.map((task) {
        if (task.id == event.task.id) {
          return updatedTask;
        }
        return task;
      }).toList();

      // Update the state with the modified task list
      emit(HomeLoaded(updatedTasks));

      // Save the completed task's timer
      if (event.task.timeSpent != null) {
        await timerService.saveTimeSpent(
            event.task.id ?? '', event.task.timeSpent ?? Duration.zero);
      }
    }
  }

  @override
  Future<void> close() {
    _timerSubscription.cancel();
    return super.close();
  }

  // Handler for navigating to task details page
  // Emits MoveToTaskDetailsState if not already in that state
  Future<void> _onMoveToTaskDetails(
      MoveToTaskDetails event, Emitter<HomeState> emit) async {
    if (state is! MoveToTaskDetailsState) {
      emit(MoveToTaskDetailsState(event.taskId));
    }
  }

  // Handler for navigating to add task page
  // Emits MoveToAddTaskPageState if not already in that state
  Future<void> _onMoveToAddTaskPage(
      MoveToAddTaskPage event, Emitter<HomeState> emit) async {
    if (state is! MoveToAddTaskPageState) {
      emit(MoveToAddTaskPageState());
    }
  }

  // Handler for deleting a task
  // Makes API call to delete task and updates state accordingly
  Future<void> _onDeleteTask(DeleteTask event, Emitter<HomeState> emit) async {
    try {
      showLoader();
      // Create REST API instance with delete endpoint
      final restApi = RestApi(endPoint: AppEndPoint.deleteTaskUrl);
      // Call repository to delete task
      await taskRepository.deleteTasks(restApi, event.task.id ?? '');
      emit(HomePageUpdateState());
    } catch (e) {
      emit(HomeError(e.toString()));
    } finally {
      hideLoader();
    }
  }

  // Handler for task completion
  // Emits completion state and refreshes task list after delay
  Future<void> _onTaskCompleted(
    TaskCompleted event,
    Emitter<HomeState> emit,
  ) async {
    emit(TaskCompletedState());
    // Wait for 2 seconds to show completion state
    await Future.delayed(const Duration(seconds: 2));
    add(FetchTasks()); // Refresh tasks after completion
  }

  // Handler for resetting navigation state
  // Returns bloc to initial state
  void _onResetNavigationState(
    ResetNavigationState event,
    Emitter<HomeState> emit,
  ) {
    emit(HomeInitial());
  }

  // Handler for updating a task
  // Makes API call to update task and emits success/error state
  Future<void> _onUpdateTask(UpdateTask event, Emitter<HomeState> emit) async {
    try {
      // Make API call to update task
      await taskRepository.updateTasks(
        RestApi(endPoint: AppEndPoint.updateTaskUrl),
        event.tasksResponse.toJson(),
      );

      emit(TaskUpdatedState());
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
