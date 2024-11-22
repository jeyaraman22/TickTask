import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/model/task_response.dart';
import '../../../services/completed_tasks_storage.dart';

// Events - Define all possible actions that can be triggered
abstract class CompletedTaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Event to trigger fetching of completed tasks from storage
class FetchCompletedTasks extends CompletedTaskEvent {}

// States - Define all possible states the UI can be in
abstract class CompletedTaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial state when bloc is created
class CompletedTaskInitial extends CompletedTaskState {}

// State while tasks are being fetched
class CompletedTaskLoading extends CompletedTaskState {}

// State when tasks are successfully loaded
class CompletedTaskLoaded extends CompletedTaskState {
  final List<TodoistTaskResponseData> tasks;

  CompletedTaskLoaded({required this.tasks});

  @override
  List<Object?> get props => [tasks];
}

// State when an error occurs during task fetching
class CompletedTaskError extends CompletedTaskState {
  final String message;

  CompletedTaskError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC to manage completed tasks state and business logic
class CompletedTaskBloc extends Bloc<CompletedTaskEvent, CompletedTaskState> {
  final CompletedTasksStorage completedTasksStorage;

  CompletedTaskBloc({
    required this.completedTasksStorage,
  }) : super(CompletedTaskInitial()) {
    on<FetchCompletedTasks>(_onFetchCompletedTasks);
  }

  // Handler for FetchCompletedTasks event
  // Retrieves completed tasks from local storage and updates state accordingly
  Future<void> _onFetchCompletedTasks(
    FetchCompletedTasks event,
    Emitter<CompletedTaskState> emit,
  ) async {
    try {
      emit(CompletedTaskLoading());

      // Get tasks from local storage only
      final completedTasks = await completedTasksStorage.getCompletedTasks();
      emit(CompletedTaskLoaded(tasks: completedTasks));
    } catch (e) {
      emit(CompletedTaskError(e.toString()));
    }
  }
}
