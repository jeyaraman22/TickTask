import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tick_task/src/core/bloc/loader_bloc.dart';
import 'package:tick_task/src/core/di/dependency.dart';
import 'package:tick_task/src/core/rest_api/rest_api_response_data.dart';
import 'package:tick_task/src/data/model/task_response.dart';
import 'package:tick_task/src/feature/home/home_bloc/home_bloc.dart';
import 'package:tick_task/src/data/repository/task_repository.dart';
import 'package:tick_task/src/services/completed_tasks_storage.dart';
import 'package:tick_task/src/services/timer_service.dart';
import 'package:tick_task/src/services/task_label_storage.dart';

import 'home_bloc_test.mocks.dart' as home_mocks;
import 'task_detail_bloc_test.mocks.dart';

@GenerateMocks([
  TaskRepository,
  TimerService,
  TaskLabelStorage,
  LoaderBloc,
  CompletedTasksStorage
])
void main() {
  late HomeBloc homeBloc;
  late MockTaskRepository mockTaskRepository;
  late MockTimerService mockTimerService;
  late home_mocks.MockTaskLabelStorage mockLabelStorage;
  late MockCompletedTasksStorage mockCompletedTasksStorage;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockTaskRepository = MockTaskRepository();
    mockTimerService = MockTimerService();
    mockLabelStorage = home_mocks.MockTaskLabelStorage();
    mockCompletedTasksStorage = MockCompletedTasksStorage();

    // Add timer updates mock with an empty stream
    when(mockTimerService.timerUpdates).thenAnswer((_) => Stream.empty());

    // Mock CompletedTasksStorage to return false by default
    when(mockCompletedTasksStorage.isTaskCompleted(any))
        .thenAnswer((_) async => false);

    // Register dependencies
    final mockLoaderBloc = MockLoaderBloc();
    SL.getIt.registerSingleton<LoaderBloc>(mockLoaderBloc);
    SL.getIt.registerSingleton<CompletedTasksStorage>(mockCompletedTasksStorage);

    homeBloc = HomeBloc(
      taskRepository: mockTaskRepository,
      timerService: mockTimerService,
      labelStorage: mockLabelStorage,
    );
  });

  tearDown(() {
    homeBloc.close();
    SL.getIt.unregister<LoaderBloc>();
    SL.getIt.unregister<CompletedTasksStorage>();
  });

  group('HomeBloc Tests', () {

    blocTest<HomeBloc, HomeState>(
      'emits [HomeError] with detailed error message when FetchTasks fails',
      build: () {
        when(mockTaskRepository.getTasks(any))
            .thenThrow(Exception('Detailed network error'));
        return homeBloc;
      },
      act: (bloc) => bloc.add(FetchTasks()),
      expect: () => [
        isA<HomeError>().having(
              (state) => state.message,
          'error message',
          contains('Detailed network error'),
        ),
      ],
      verify: (bloc) {
        verify(mockTaskRepository.getTasks(any)).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'handles empty task list correctly',
      build: () {
        when(mockTaskRepository.getTasks(any)).thenAnswer(
              (_) async => ApiResponseWrapper(
            restApiResponseData: RestApiResponseData(
              200,
              [], // Empty task list
              'OK',
            ),
          ),
        );

        return homeBloc;
      },
      act: (bloc) => bloc.add(FetchTasks()),
      expect: () => [
        isA<HomeLoaded>().having(
              (state) => state.tasks.length,
          'tasks length',
          0,
        ),
      ],
    );
  });
}
