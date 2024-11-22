import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tick_task/src/core/rest_api/rest_api.dart';
import 'package:tick_task/src/core/rest_api/rest_api_response_data.dart';
import 'package:tick_task/src/data/repository/comments_repository.dart';
import 'package:tick_task/src/data/model/comments_response.dart';

import 'task_repository_test.mocks.dart';

@GenerateMocks([RestApi])
void main() {
  late CommentsRepository commentsRepository;
  late MockRestApi mockRestApi;

  setUp(() {
    mockRestApi = MockRestApi();
    commentsRepository = CommentsRepository.instance;
  });

  group('CommentsRepository Tests', () {
    final mockComment = CommentsResponse(
      id: '1',
      content: 'Test Comment',
      taskId: 'task-1',
    );

    test('getComments returns success response', () async {
      final mockResponseData = RestApiResponseData<List<CommentsResponse>>(
        200,
        [mockComment],
        'OK',
      );

      when(mockRestApi.executeForList<CommentsResponse>(
        parser: anyNamed('parser'),
      )).thenAnswer((_) async => mockResponseData);

      final result =
          await commentsRepository.getComments(mockRestApi, 'task-1');

      expect(result.isSuccessCode, true);
      expect(result.data?.length, 1);
      expect(result.data?.first.content, 'Test Comment');
      verify(mockRestApi.executeForList<CommentsResponse>(
        parser: anyNamed('parser'),
      )).called(1);
    });

    test('addComments returns success response', () async {
      final mockResponseData = RestApiResponseData<CommentsResponse>(
        201,
        mockComment,
        'OK',
      );

      when(mockRestApi.execute<CommentsResponse>(
        parser: anyNamed('parser'),
      )).thenAnswer((_) async => mockResponseData);

      final result = await commentsRepository.addComments(
        mockRestApi,
        {'content': 'Test Comment', 'task_id': 'task-1'},
      );

      expect(result.isSuccessCode, true);
      expect(result.data?.content, 'Test Comment');
    });
  });
}
