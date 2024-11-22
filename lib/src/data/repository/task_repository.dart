import 'package:tick_task/src/core/rest_api/rest_api.dart';
import 'package:tick_task/src/core/rest_api/rest_api_response_data.dart';
import 'package:tick_task/src/data/model/task_response.dart';

class TaskRepository {
  TaskRepository._internal();

  factory TaskRepository() => instance;

  static TaskRepository instance = TaskRepository._internal();

  Future<ApiResponseWrapper<List<TodoistTaskResponseData>>> getTasks(
      RestApi restApi) async {
    // as per the given scope, we only fetching the tasks from the particular project
    restApi.queryParameters = {'project_id': '2343636981'};
    RestApiResponseData<List<TodoistTaskResponseData>> responseData =
        await restApi.executeForList<TodoistTaskResponseData>(
            parser: (json) =>
                json.map((i) => TodoistTaskResponseData.fromJson(i)).toList());
    final data = ApiResponseWrapper<List<TodoistTaskResponseData>>(
        restApiResponseData: responseData);

    return data;
  }

  Future<ApiResponseWrapper<TodoistTaskResponseData>> getTaskById(
      RestApi restApi, String taskId) async {
    restApi.paths = [taskId];
    ApiResponseWrapper<TodoistTaskResponseData> data =
        await _executeTaskApi(restApi);
    return data;
  }

  Future<ApiResponseWrapper<TodoistTaskResponseData>> addTasks(
      RestApi restApi, Map<String, dynamic> body) async {
    return await _commonCallForAddAndUpdateTask(restApi, body);
  }

  Future<ApiResponseWrapper<TodoistTaskResponseData>> updateTasks(
      RestApi restApi, Map<String, dynamic> body) async {
    restApi.paths = [body['id']];
    return await _commonCallForAddAndUpdateTask(restApi, body);
  }

  Future<ApiResponseWrapper> deleteTasks(
      RestApi restApi, String taskId) async {
    restApi.paths = [taskId];
    return await _deleteTaskCall(restApi);
  }

  Future<ApiResponseWrapper<TodoistTaskResponseData>>
      _commonCallForAddAndUpdateTask(
          RestApi restApi, Map<String, dynamic> body) async {
    restApi.requestParameters = body;
    restApi.queryParameters = {'project_id': '2343636981'};
    ApiResponseWrapper<TodoistTaskResponseData> data =
        await _executeTaskApi(restApi);
    return data;
  }

  Future<ApiResponseWrapper<dynamic>> _deleteTaskCall(
      RestApi restApi) async {
    RestApiResponseData responseData = await restApi.execute();
    final data = ApiResponseWrapper(restApiResponseData: responseData);
    return data;
  }

  Future<ApiResponseWrapper<TodoistTaskResponseData>> _executeTaskApi(
      RestApi restApi) async {
    RestApiResponseData<TodoistTaskResponseData> responseData =
        await restApi.execute<TodoistTaskResponseData>(
            parser: (json) => TodoistTaskResponseData.fromJson(json));
    final data = ApiResponseWrapper<TodoistTaskResponseData>(
        restApiResponseData: responseData);
    return data;
  }
}
