import 'package:dio/dio.dart';

import '../network/http_client.dart';

// Client class for handling REST API HTTP requests using Dio
class RestHttpClient {
  RestHttpClient();

  // Instance of HttpClient for making network requests
  final _httpClient = HttpClient();

  // Makes an HTTP request and returns the response as a Map
  // Parameters:
  // - url: The endpoint URL
  // - method: HTTP method (GET, POST, PUT, DELETE)
  // - headers: Optional request headers
  // - parameters: Optional request body/parameters
  Future<Response<dynamic>> request(
      {required String url,
      required RestApiMethod method,
      Map<String, String>? headers,
      dynamic parameters}) async {
    try {
      late final Response<dynamic> response;
      final options = Options(headers: headers);

      // Execute different HTTP methods based on the method parameter
      switch (method) {
        case RestApiMethod.get:
          response = await _httpClient.dio.get(url, options: options);
          break;
        case RestApiMethod.put:
          response = await _httpClient.dio
              .put(url, data: parameters, options: options);
          break;
        case RestApiMethod.post:
          response = await _httpClient.dio
              .post(url, data: parameters, options: options);
          break;
        case RestApiMethod.delete:
          response = await _httpClient.dio
              .delete(url, data: parameters, options: options);
          break;
      }
     return response;
    } on DioException catch (e) {
      throw Exception('Failed to make API request: $e');
    }
  }
}

// Enum defining supported HTTP methods
enum RestApiMethod { get, put, post, delete }
