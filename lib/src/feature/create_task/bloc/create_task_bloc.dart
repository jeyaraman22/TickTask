import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tick_task/src/core/bloc/loader_mixin.dart';
import 'package:tick_task/src/core/di/dependency.dart';
import 'package:tick_task/src/core/rest_api/rest_api.dart';
import 'package:tick_task/src/core/rest_api/rest_api_endpoint.dart';
import 'package:tick_task/src/data/model/custom_task_data.dart';
import 'package:tick_task/src/data/repository/task_repository.dart';
import 'package:tick_task/src/feature/create_task/create_task_page.dart';

// Base event class for all create task events
abstract class CreateTaskEvent {}

// Event triggered when user submits a new task
class SubmitTaskEvent extends CreateTaskEvent {
  final TaskItem task;
  final TaskCategory category;

  SubmitTaskEvent(this.task, this.category);
}

// Base state class for all create task states
abstract class CreateTaskState {}

// Initial state when the bloc is created
class CreateTaskInitial extends CreateTaskState {}

// State while task is being created
class CreateTaskLoading extends CreateTaskState {}

// State when task creation is successful
class CreateTaskSuccess extends CreateTaskState {
  final TaskItem task;
  final TaskCategory category;

  CreateTaskSuccess(this.task, this.category);
}

// State when task creation fails
class CreateTaskError extends CreateTaskState {
  final String error;

  CreateTaskError(this.error);
}

// BLoC to handle task creation logic
class CreateTaskBloc extends Bloc<CreateTaskEvent, CreateTaskState>
    with LoaderMixin {
  // Repository instance for task operations
  final TaskRepository _taskRepository = SL.get<TaskRepository>();

  CreateTaskBloc() : super(CreateTaskInitial()) {
    on<SubmitTaskEvent>(_onSubmitTask);
  }

  // Handler for task submission
  Future<void> _onSubmitTask(
    SubmitTaskEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    // Show loading indicator
    showLoader();
    try {
      // Make API call to create task
      final response = await _taskRepository.addTasks(
        RestApi(endPoint: AppEndPoint.createTaskUrl),
        event.task.toJson(),
      );

      // Handle API response
      if (response.isSuccessCode) {
        emit(CreateTaskSuccess(event.task, event.category));
      } else {
        emit(CreateTaskError('Failed to create task'));
      }
    } catch (e) {
      // Handle any errors during task creation
      emit(CreateTaskError(e.toString()));
    } finally {
      // Hide loading indicator
      hideLoader();
    }
  }
}
