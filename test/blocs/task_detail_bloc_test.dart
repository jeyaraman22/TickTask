import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tick_task/src/core/bloc/loader_bloc.dart';
import 'package:tick_task/src/core/di/dependency.dart';
import 'package:tick_task/src/core/rest_api/rest_api_response_data.dart';
import 'package:tick_task/src/feature/task_detail/bloc/task_detail_bloc.dart';
import 'package:tick_task/src/data/repository/task_repository.dart';
import 'package:tick_task/src/data/repository/comments_repository.dart';
import 'package:tick_task/src/services/app_preferences_service.dart';
import 'package:tick_task/src/services/timer_service.dart';
import 'package:tick_task/src/services/completed_tasks_storage.dart';
import 'package:tick_task/src/data/model/task_response.dart';
import 'package:tick_task/src/data/model/comments_response.dart';


import 'task_detail_bloc_test.mocks.dart';

class MockAppPreferencesService extends Mock implements AppPreferencesService {}

@GenerateMocks([
  TaskRepository,
  CommentsRepository,
  TimerService,
  CompletedTasksStorage,
  LoaderBloc
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TaskDetailBloc taskDetailBloc;
  late MockTaskRepository mockTaskRepository;
  late MockCommentsRepository mockCommentsRepository;
  late MockTimerService mockTimerService;
  late MockCompletedTasksStorage mockCompletedTasksStorage;
  late MockAppPreferencesService mockAppPreferencesService;
  late MockLoaderBloc mockLoaderBloc;
  late SharedPreferences prefs;


  final mockTask = TodoistTaskResponseData(
    id: '1',
    content: 'Test Task',
    description: 'Test Description',
  );

  final mockComment = CommentsResponse(
    id: '1',
    content: 'Test Comment',
    taskId: '1',
  );

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    mockTaskRepository = MockTaskRepository();
    mockCommentsRepository = MockCommentsRepository();
    mockTimerService = MockTimerService();
    mockCompletedTasksStorage = MockCompletedTasksStorage();
    mockAppPreferencesService = MockAppPreferencesService();
    mockLoaderBloc = MockLoaderBloc();

    SL.getIt
        .registerSingleton<AppPreferencesService>(mockAppPreferencesService);
    SL.getIt.registerSingleton<LoaderBloc>(mockLoaderBloc);
    SL.getIt.registerSingleton<TimerService>(mockTimerService);

    when(mockTimerService.timerUpdates).thenAnswer((_) => const Stream.empty());

    taskDetailBloc = TaskDetailBloc(
      taskRepository: mockTaskRepository,
      commentsRepository: mockCommentsRepository,
      timerService: mockTimerService,
      completedTasksStorage: mockCompletedTasksStorage,
    );
  });

  // tearDownAll(() {
  //   taskDetailBloc.close();
  // });

  group('TaskDetailBloc Tests', () {
    blocTest<TaskDetailBloc, TaskDetailState>(
      'emits [TaskDetailLoaded] when LoadTaskAndComments succeeds',
      build: () {
        when(mockTaskRepository.getTaskById(any, '1')).thenAnswer(
          (_) async => ApiResponseWrapper(
            restApiResponseData: RestApiResponseData(200, mockTask, 'OK'),
          ),
        );
        when(mockCommentsRepository.getComments(any, '1')).thenAnswer(
          (_) async => ApiResponseWrapper(
            restApiResponseData: RestApiResponseData(200, [mockComment], 'OK'),
          ),
        );
        return taskDetailBloc;
      },
      act: (bloc) => bloc.add(const LoadTaskAndComments('1')),
      expect: () => [
        isA<TaskDetailLoaded>().having(
          (state) => state.task.id,
          'task id',
          '1',
        ),
      ],
    );

    blocTest<TaskDetailBloc, TaskDetailState>(
      'emits [TaskDetailError] when LoadTaskAndComments fails',
      build: () {
        when(mockTaskRepository.getTaskById(any, any))
            .thenThrow(Exception('Failed to load task'));
        return TaskDetailBloc(
          taskRepository: mockTaskRepository,
          commentsRepository: mockCommentsRepository,
          timerService: mockTimerService,
          completedTasksStorage: mockCompletedTasksStorage,
        );;
      },
      act: (bloc) => bloc.add(const LoadTaskAndComments('1')),
      expect: () => [isA<TaskDetailError>()],
    );

    blocTest<TaskDetailBloc, TaskDetailState>(
      'handles StartTimer event correctly',
      build: () => TaskDetailBloc(
      taskRepository: mockTaskRepository,
      commentsRepository: mockCommentsRepository,
      timerService: mockTimerService,
      completedTasksStorage: mockCompletedTasksStorage,
    ),
      seed: () => TaskDetailLoaded(
        task: mockTask,
        comments: const [],
        timeSpent: Duration.zero,
        isTimerRunning: false,
      ),
      act: (bloc) => bloc.add(const StartTimer('1')),
      expect: () => [
        isA<TaskDetailLoaded>().having(
          (state) => state.isTimerRunning,
          'timer running',
          true,
        ),
      ],
    );
  });
}
