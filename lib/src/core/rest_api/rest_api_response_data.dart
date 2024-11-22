import '../network/api_constants.dart';

// A generic class to handle REST API response data structure
// [T] represents the type of data expected in the response
class RestApiResponseData<T> {
  // HTTP status code of the response
  final int? code;

  // Parsed response data of type [T]
  final T? data;

  // Error message or response message
  final String? message;

  RestApiResponseData(this.code, this.data, this.message);

  // Method to create [RestApiResponseData] from JSON
  // [json] - Raw JSON response from API
  // [parser] - Function to parse the data portion of the response into type [T]
  static RestApiResponseData<T> fromJson<T>(
      dynamic json, T Function(dynamic json) parser) {
    final data = json.data;
    return RestApiResponseData<T>(
        json.statusCode, data != null ? parser(data) : null, json.statusMessage);
  }
}

// Wrapper class to provide convenient access to API response data
// and common status checks
class ApiResponseWrapper<T> {
  final RestApiResponseData<T> restApiResponseData;
  ApiResponseWrapper({required this.restApiResponseData});

  // Returns the parsed data from the response
  T? get data {
    return restApiResponseData.data;
  }

  // Checks if response contains valid data
  bool get hasData {
    return data != null;
  }

  // Checks if response contains an error
  // Returns true if there's no data but has an error message
  bool get hasError {
    return data == null && restApiResponseData.message != null;
  }

  // Returns error message or default error message if none provided
  String get errorMessage {
    return restApiResponseData.message ?? somethingWentWrong;
  }

  // Checks if response has a success status code
  bool get isSuccessCode {
    return restApiResponseData.code == successCode || restApiResponseData.message == ok;
  }

  // Checks if response has a creation success status code
  bool get createStatus {
    return restApiResponseData.code == createCode;
  }
}
