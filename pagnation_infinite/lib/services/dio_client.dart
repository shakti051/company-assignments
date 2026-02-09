import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dio_error_handler.dart';

class DioClient {
  late final Dio dio;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        headers: {'Accept': 'application/json'},
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint(' ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(' ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          final apiException = DioErrorHandler.handle(error);
          debugPrint(apiException.message);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: apiException,
            ),
          );
        },
      ),
    );
  }

  static final DioClient _instance = DioClient._internal();

  factory DioClient() => _instance;
}
