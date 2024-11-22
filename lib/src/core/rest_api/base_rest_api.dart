import 'package:tick_task/src/core/network/api_constants.dart';
import 'package:tick_task/src/core/rest_api/rest_api_response_data.dart';
import 'package:tick_task/src/core/rest_api/rest_http_client.dart';

// Class to hold API request attributes
abstract class RestApiAttributes {
  // The API endpoint path
  String endPoint;
  // HTTP method for the request (GET, POST, etc.)
  RestApiMethod restApiMethod;
  // Body parameters for POST/PUT requests
  Map<String, dynamic>? requestParameters;
  // URL query parameters
  Map<String, dynamic>? queryParameters;
  // List of paths for the API endpoint
  List<dynamic> paths;

  RestApiAttributes(
      {required this.endPoint,
      required this.restApiMethod,
      this.requestParameters = const {},
      this.queryParameters = const {},
      this.paths = const []});
}

// Main class for handling REST API requests
abstract class BaseRestApi {
  RestApiAttributes appEndPoint;

  List<dynamic> paths;
  Map<String, dynamic> queryParameters;

  BaseRestApi(
      {required this.appEndPoint,
      this.paths = const [],
      this.queryParameters = const {}});

  //Parameters
  Map<String, dynamic> _parameters = {};

  //getter
  Map<String, dynamic> get requestParameters {
    return _parameters;
  }

  //setter
  set requestParameters(dynamic parameters) {
    _parameters = parameters;
  }

  // Returns headers for the HTTP request with default content type
  Map<String, String> getHeaders() {
    Map<String, String> headers = {"Content-Type": "application/json"};
    headers["Authorization"] = "Bearer $accessToken";
    // add more headers here based on the user preferences
    // ... add more header here
    return headers;
  }

  // Constructs the complete URL by combining base URL, endpoints, and query parameters
  String getUrl() {
    // Get the endpoint from attributes
    String endPoints = appEndPoint.endPoint;
    for (dynamic path in paths) {
      ///This condition check has been done because some of the non-revamped path has the '/' which remove will affect the revamp module,once the revamp completed the function can be removed.
      endPoints = "$endPoints/$path";
    }
    // Convert query parameters to URL format
    final queryString = Uri(queryParameters: queryParameters).query;
    if (queryString.isNotEmpty) {
      endPoints = "$endPoints?$queryString";
    }

    return baseApiUrl + endPoints;
  }

  // Executes the API request and returns parsed response
  // Generic type T represents the expected response data type
  Future<RestApiResponseData<T>> execute<T>(
      {T Function(dynamic json)? parser}) async {
    final restHttpClient = RestHttpClient();

    // Make the HTTP request
    final json = await restHttpClient.request(
        url: getUrl(),
        method: appEndPoint.restApiMethod,
        parameters: requestParameters,
        headers: getHeaders());

    RestApiResponseData<T> parsedResponse;

    if (json.statusCode == successCode || json.statusMessage == ok || json.statusCode == 204) {
      // Parse the response using provided parser or return raw data
      parsedResponse = RestApiResponseData.fromJson<T>(
          json, (data) => parser != null ? parser(data) : data);
      return parsedResponse;
    }

    parsedResponse =
        RestApiResponseData<T>(json.statusCode, null, json.statusMessage);

    return parsedResponse;
  }

  Future<RestApiResponseData<List<T>>> executeForList<T>(
      {List<T> Function(List<dynamic> json)? parser}) async {
    final restHttpClient = RestHttpClient();
    final json = await restHttpClient.request(
        url: getUrl(),
        method: appEndPoint.restApiMethod,
        parameters: requestParameters,
        headers: getHeaders());

    RestApiResponseData<List<T>> parsedResponse;

    if (json.statusCode == successCode || json.statusMessage == ok) {
      // Parse the response using provided parser or return raw data
      parsedResponse = RestApiResponseData.fromJson<List<T>>(
          json, (data) => parser != null ? parser(data) : data);
      return parsedResponse;
    }

    parsedResponse =
        RestApiResponseData<List<T>>(json.statusCode, null, json.statusMessage);

    return parsedResponse;
  }
}
