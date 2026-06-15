import 'package:dio/dio.dart';

class ErrorHandler {
  static String handle(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Please try again.';
      case DioExceptionType.badResponse:
        final response = error.response;
        if (response != null) {
          final statusCode = response.statusCode;
          final data = response.data;
          if (data is Map && data.containsKey('message')) {
            return data['message'].toString();
          }
          if (statusCode == 400) {
            return 'Invalid request. Please check your inputs.';
          } else if (statusCode == 401) {
            return 'Unauthorized. Please log in again.';
          } else if (statusCode == 403) {
            return 'Forbidden request.';
          } else if (statusCode == 404) {
            return 'Resource not found on server.';
          } else if (statusCode == 500) {
            return 'Internal server error. Please try again later.';
          }
        }
        return 'Received invalid response from server (${response?.statusCode ?? "unknown"}).';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'Network connection error. Please verify your connection.';
      case DioExceptionType.badCertificate:
        return 'Secure connection failed due to an invalid server certificate.';
      case DioExceptionType.unknown:
        if (error.message != null && error.message!.contains('SocketException')) {
          return 'No internet connection. Please verify your connection.';
        }
        return error.message ?? 'An unknown network error occurred.';
    }
  }
}
