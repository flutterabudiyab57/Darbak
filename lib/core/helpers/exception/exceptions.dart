import 'dart:async';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// ----------------------
/// Exceptions
/// ----------------------
class AppException implements Exception {
  final String? message;
  final dynamic details;
  final dynamic data;

  const AppException([this.message, this.details, this.data]);

  @override
  String toString() => "message: $message -> Details: $details";
}

class FetchDataException extends AppException {
  const FetchDataException({required String details, data})
      : super("Error During Communication.", details, data);
}

class BadRequestException extends AppException {
  const BadRequestException([details]) : super("Invalid Request.", details);
}

class UnProcessableEntity extends AppException {
  const UnProcessableEntity(message, {required Map<String, dynamic> details})
      : super(message, details);
}

class UnAuthenticatedException extends AppException {
  const UnAuthenticatedException([details]) : super("Unauthorised.", details);
}

class EmailNotFoundException extends AppException {
  const EmailNotFoundException({required String message}) : super(message);

  @override
  String toString() => 'EmailNotFoundException (message: $message)';
}

class ResetPasswordCodeNotValidException extends AppException {
  const ResetPasswordCodeNotValidException(String message) : super(message);

  @override
  String toString() =>
      'ResetPasswordCodeNotValidExeption(message: $message)';
}

class EmailAlreadyUsedException extends AppException {
  const EmailAlreadyUsedException(String message) : super(message);

  @override
  String toString() => 'EmailAlreadyUsedException(message: $message)';
}

class PreferenceUtilsNotInitializedException extends AppException {
  const PreferenceUtilsNotInitializedException(String message) : super(message);
}

class NotSupportedTypeToSaveException extends AppException {}

class NotFoundRouteException extends AppException {}

/// Exception مخصص لانقطاع الإنترنت
class NoInternetConnectionException extends AppException {
  const NoInternetConnectionException()
      : super("No Internet Connection", "Please check your network");
}

/// ----------------------
/// Failure Wrapper
/// ----------------------
class Failure implements Exception {
  late String message;

  @override
  String toString() => message;

  Failure.fromDioError(DioException DioException) {
    switch (DioException.type) {
      case DioExceptionType.cancel:
        message = "Request to API server was cancelled";
        break;
      case DioExceptionType.connectionTimeout:
        message = "Connection timeout with server";
        break;
      case DioExceptionType.receiveTimeout:
        message = "Receive timeout in connection with server";
        break;
      case DioExceptionType.sendTimeout:
        message = "Send timeout in connection with server";
        break;
      case DioExceptionType.unknown:
        message = "Connection failed due to internet connection";
        break;
      case DioExceptionType.badResponse:
        message = handleError(DioException)!;
        break;
      default:
        message = "Something went wrong";
        break;
    }
  }

  String? handleError(DioException DioException) {
    final statusCodeMessages = {
      500: "Server Error",
      401: "Not Authenticated",
      422: "Data is not valid",
      404: "Data Not Found",
      429: "Too many requests",
      403: "Your Request Is Not Allowed",
    };
    return statusCodeMessages[DioException.response?.statusCode] ??
        DioException.message;
  }
}

/// ----------------------
/// Safe API Call
/// ----------------------
Future<Response> safeApiCall(Future<Response> Function() apiCall) async {
  final connectivityResult = await Connectivity().checkConnectivity();
  final hasConnection = connectivityResult != ConnectivityResult.none;

  if (!hasConnection) {
    throw const NoInternetConnectionException();
  } else {
  }

  try {
    return await apiCall();
  } on DioException catch (DioException) {
    throw Failure.fromDioError(DioException);
  } catch (e) {
    throw AppException("Unexpected error", e.toString());
  }
}
