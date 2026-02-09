import 'package:dio/dio.dart';
import 'api_exception.dart';

class DioErrorHandler {
  static ApiException handle(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(message: 'Connection timeout');

      case DioExceptionType.sendTimeout:
        return ApiException(message: 'Request timeout');

      case DioExceptionType.receiveTimeout:
        return ApiException(message: 'Response timeout');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message =
            error.response?.data?['message'] ??
            'Server error ($statusCode)';
        return ApiException(
          message: message,
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return ApiException(message: 'Request cancelled');

      case DioExceptionType.unknown:
      default:
        return ApiException(message: 'No internet connection');
    }
  }
}