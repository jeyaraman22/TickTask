import 'base_rest_api.dart';

class RestApi extends BaseRestApi {
  //Constructor
  RestApi(
      {required RestApiAttributes endPoint, super.paths, super.queryParameters})
      : super(appEndPoint: endPoint);
}
