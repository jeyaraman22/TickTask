import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

// Client class for handling HTTP requests using Dio
class HttpClient {
  HttpClient();

  // Getter for configured Dio instance
  Dio get dio => _getDio();

  // Creates and configures a Dio instance with default settings
  Dio _getDio() {
    final options = BaseOptions(
        baseUrl: '',
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        receiveDataWhenStatusError: true);

    final dio = Dio(options);

    // Add logging interceptor for request/response logging
    dio.interceptors.addAll(<Interceptor>[_loggingInterceptor()]);

    return dio;
  }

  // Creates an interceptor for logging network requests and responses
  Interceptor _loggingInterceptor() {
    return InterceptorsWrapper(
      // Log outgoing requests
      onRequest: (options, handler) async {
        log("--> ${options.method} ${"${options.baseUrl}${options.path}"}");
        log("--> request : \n'${options.data}");
        return handler.next(options);
      },
      // Log incoming responses
      onResponse: (response, handler) async {
        log('Response of : ${response.requestOptions.uri} \n'
            '-- response --\n'
            '${jsonEncode(response.data)} \n');
        return handler.next(response);
      },
    );
  }
}
