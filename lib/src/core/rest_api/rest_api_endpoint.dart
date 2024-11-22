import 'package:tick_task/src/core/rest_api/rest_http_client.dart';

import 'base_rest_api.dart';

class AppEndPoint extends RestApiAttributes {
  AppEndPoint._internal(String key, RestApiMethod method)
      : super(endPoint: key, restApiMethod: method);

  // get available tasks endpoint
  static AppEndPoint getTaskUrl =
      AppEndPoint._internal("tasks", RestApiMethod.get);

  // get comments for a specific task endpoint
  static AppEndPoint getCommentsUrl =
      AppEndPoint._internal("comments", RestApiMethod.get);

  // add the task endpoint
  static AppEndPoint createTaskUrl =
      AppEndPoint._internal("tasks", RestApiMethod.post);

  // add the comments for a specific task endpoint
  static AppEndPoint createCommentsUrl =
      AppEndPoint._internal("comments", RestApiMethod.post);

  // update the task endpoint
  static AppEndPoint updateTaskUrl =
      AppEndPoint._internal("tasks", RestApiMethod.post);

  // delete the task endpoint
  static AppEndPoint updateCommentsUrl =
      AppEndPoint._internal("comments", RestApiMethod.post);

  // delete the task endpoint
  static AppEndPoint deleteTaskUrl =
      AppEndPoint._internal("tasks", RestApiMethod.delete);

  // delete the comments for a specific task endpoint
  static AppEndPoint deleteCommentsUrl =
      AppEndPoint._internal("comments", RestApiMethod.delete);
}
