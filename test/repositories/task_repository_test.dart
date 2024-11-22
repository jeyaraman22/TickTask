import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tick_task/src/core/rest_api/rest_api.dart';
import 'package:tick_task/src/core/rest_api/rest_api_response_data.dart';
import 'package:tick_task/src/data/repository/task_repository.dart';
import 'package:tick_task/src/data/model/task_response.dart';

import 'task_repository_test.mocks.dart';

@GenerateMocks([RestApi])
void main() {
  late TaskRepository taskRepository;
  late MockRestApi mockRestApi;

  setUp(() {
    mockRestApi = MockRestApi();
    taskRepository = TaskRepository.instance;
  });

  group('TaskRepository Tests', () {
    final mockTaskData = TodoistTaskResponseData(
      id: '1',
      content: 'Test Task',
      description: 'Test Description',
    );

    test('getTasks returns success response', () async {
      final mockResponseData =
          RestApiResponseData<List<TodoistTaskResponseData>>(
        200,
        [mockTaskData],
        'OK',
      );

      when(mockRestApi.executeForList<TodoistTaskResponseData>(
        parser: anyNamed('parser'),
      )).thenAnswer((_) async => mockResponseData);

      final result = await taskRepository.getTasks(mockRestApi);

      expect(result.isSuccessCode, true);
      expect(result.data?.length, 1);
      expect(result.data?.first.content, 'Test Task');
      verify(mockRestApi.executeForList<TodoistTaskResponseData>(
        parser: anyNamed('parser'),
      )).called(1);
    });

    test('addTasks returns success response', () async {
      final mockResponseData = RestApiResponseData<TodoistTaskResponseData>(
        201,
        mockTaskData,
        'OK',
      );

      when(mockRestApi.execute<TodoistTaskResponseData>(
        parser: anyNamed('parser'),
      )).thenAnswer((_) async => mockResponseData);

      final result = await taskRepository.addTasks(
        mockRestApi,
        {'content': 'Test Task'},
      );

      expect(result.isSuccessCode, true);
      expect(result.data?.content, 'Test Task');
      verify(mockRestApi.execute<TodoistTaskResponseData>(
        parser: anyNamed('parser'),
      )).called(1);
    });

    test('updateTasks returns success response', () async {
      final mockResponseData = RestApiResponseData<TodoistTaskResponseData>(
        200,
        mockTaskData,
        'OK',
      );

      when(mockRestApi.execute<TodoistTaskResponseData>(
        parser: anyNamed('parser'),
      )).thenAnswer((_) async => mockResponseData);

      final result = await taskRepository.updateTasks(
        mockRestApi,
        {'id': '1', 'content': 'Updated Task'},
      );

      expect(result.isSuccessCode, true);
      expect(result.data?.id, '1');
      verify(mockRestApi.execute<TodoistTaskResponseData>(
        parser: anyNamed('parser'),
      )).called(1);
    });

    test('deleteTasks returns success response', () async {
      final mockResponseData = RestApiResponseData(200, null, 'OK');

      when(mockRestApi.execute()).thenAnswer((_) async => mockResponseData);

      final result = await taskRepository.deleteTasks(mockRestApi, '1');

      expect(result.isSuccessCode, true);
      verify(mockRestApi.execute()).called(1);
    });

    test('getTaskById returns success response', () async {
      final mockResponseData = RestApiResponseData<TodoistTaskResponseData>(
        200,
        mockTaskData,
        'OK',
      );

      when(mockRestApi.execute<TodoistTaskResponseData>(
        parser: anyNamed('parser'),
      )).thenAnswer((_) async => mockResponseData);

      final result = await taskRepository.getTaskById(mockRestApi, '1');

      expect(result.isSuccessCode, true);
      expect(result.data?.id, '1');
      verify(mockRestApi.execute<TodoistTaskResponseData>(
        parser: anyNamed('parser'),
      )).called(1);
    });

    test('handles error responses', () async {
      final mockResponseData = RestApiResponseData<TodoistTaskResponseData>(
        400,
        null,
        'Bad Request',
      );

      when(mockRestApi.execute<TodoistTaskResponseData>(
        parser: anyNamed('parser'),
      )).thenAnswer((_) async => mockResponseData);

      final result = await taskRepository.getTaskById(mockRestApi, '1');

      expect(result.isSuccessCode, false);
      expect(result.hasError, true);
      expect(result.errorMessage, 'Bad Request');
    });
  });
}
