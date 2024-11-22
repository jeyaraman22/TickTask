import 'package:tick_task/src/core/rest_api/rest_api_endpoint.dart';
import 'package:tick_task/src/data/model/comments_response.dart';

import '../../core/rest_api/rest_api.dart';
import '../../core/rest_api/rest_api_response_data.dart';

class CommentsRepository {
  CommentsRepository._internal();

  factory CommentsRepository() {
    return instance;
  }

  static CommentsRepository instance = CommentsRepository._internal();

  Future<ApiResponseWrapper<List<CommentsResponse>>> getComments(RestApi restApi,String taskId) async {
    restApi.queryParameters = {'task_id': taskId};
    RestApiResponseData<List<CommentsResponse>> responseData =
        await restApi.executeForList<CommentsResponse>(
            parser: (json) =>
                json.map((i) => CommentsResponse.fromJson(i)).toList());
    final data = ApiResponseWrapper<List<CommentsResponse>>(
        restApiResponseData: responseData);

    return data;
  }

  Future<ApiResponseWrapper<CommentsResponse>> addComments(RestApi restApi, Map<String, dynamic> body) async {
    restApi.requestParameters = body;
    RestApiResponseData<CommentsResponse> responseData =
        await restApi.execute<CommentsResponse>(parser: (json) => CommentsResponse.fromJson(json));
    final data = ApiResponseWrapper<CommentsResponse>(
        restApiResponseData: responseData);

    return data;
  }

  Future<ApiResponseWrapper<CommentsResponse>> updateComments(RestApi restApi, Map<String, dynamic> body) async {
    restApi.paths = [body['id']];
    restApi.requestParameters = {"content": body['content']};
    RestApiResponseData<CommentsResponse> responseData =
        await restApi.execute<CommentsResponse>(
            parser: (json) => CommentsResponse.fromJson(json));
    final data = ApiResponseWrapper<CommentsResponse>(
        restApiResponseData: responseData);

    return data;
  }

  Future<ApiResponseWrapper> deleteComments(RestApi restApi, String commentsId) async {
   RestApi restApi =  RestApi(endPoint: AppEndPoint.deleteCommentsUrl);
    restApi.paths = [commentsId];
    RestApiResponseData responseData = await restApi.execute();
    final data = ApiResponseWrapper(restApiResponseData: responseData);

    return data;
  }
}
