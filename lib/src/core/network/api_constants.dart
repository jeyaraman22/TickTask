// app base url [Todoist services]
const String baseApiUrl = "https://api.todoist.com/rest/v2/";
// Todoist app test token
const String accessToken = "f16cadbd58ec75332df62a723105b9e54e173efc";
// Todoist project ID - Handling tasks for this scope
const String projectID = "2343636981";

// status codes
const num successCode = 200;
const num createCode = 201;
const num badRequestCode = 400;
const num unAuthorizedCode = 401;
const num userAccessNotAllowedCode = 403;
const num resourceNotExistCode = 404;
const num internalServerErrorCode = 500;
const num serverUnAvailableCode = 503;

// success message
const String ok = "OK";

// error message
const String somethingWentWrong = "Something went wrong";
const String noInternetError = "Please verify your internet connection";