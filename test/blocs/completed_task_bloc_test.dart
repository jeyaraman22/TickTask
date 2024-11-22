import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tick_task/src/feature/completed_task/bloc/completed_task_bloc.dart';
import 'package:tick_task/src/services/completed_tasks_storage.dart';
import 'package:tick_task/src/data/model/task_response.dart';

import 'task_detail_bloc_test.mocks.dart';

@GenerateMocks([CompletedTasksStorage])
void main() {
  late CompletedTaskBloc completedTaskBloc;
  late MockCompletedTasksStorage mockStorage;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockStorage = MockCompletedTasksStorage();
    completedTaskBloc = CompletedTaskBloc(completedTasksStorage: mockStorage);
  });

  tearDown(() {
    completedTaskBloc.close();
  });

  final mockTasks = [
    TodoistTaskResponseData(
      id: '1',
      content: 'Test Task 1',
      timeSpent: const Duration(minutes: 30),
    ),
    TodoistTaskResponseData(
      id: '2',
      content: 'Test Task 2',
      timeSpent: const Duration(hours: 1),
    ),
  ];

  group('CompletedTaskBloc Tests', () {
    blocTest<CompletedTaskBloc, CompletedTaskState>(
      'emits [CompletedTaskLoading, CompletedTaskLoaded] when FetchCompletedTasks succeeds',
      build: () {
        when(mockStorage.getCompletedTasks())
            .thenAnswer((_) async => mockTasks);
        return completedTaskBloc;
      },
      act: (bloc) => bloc.add(FetchCompletedTasks()),
      expect: () => [
        isA<CompletedTaskLoading>(),
        isA<CompletedTaskLoaded>().having(
          (state) => state.tasks.length,
          'tasks length',
          2,
        ),
      ],
    );

    blocTest<CompletedTaskBloc, CompletedTaskState>(
      'emits [CompletedTaskLoading, CompletedTaskError] when FetchCompletedTasks fails',
      build: () {
        when(mockStorage.getCompletedTasks())
            .thenThrow(Exception('Failed to load tasks'));
        return completedTaskBloc;
      },
      act: (bloc) => bloc.add(FetchCompletedTasks()),
      expect: () => [
        isA<CompletedTaskLoading>(),
        isA<CompletedTaskError>().having(
          (state) => state.message,
          'error message',
          contains('Failed to load tasks'),
        ),
      ],
    );
  });
}
