import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  late final Dio dio;

  final SecureStorage storage;

  ApiClient(this.storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.get(
        path,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
  }) async {
    try {
      return await dio.post(
        path,
        data: data,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
  }) async {
    try {
      return await dio.put(
        path,
        data: data,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<dynamic>> delete(
    String path,
  ) async {
    try {
      return await dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  AppException _handleError(DioException error) {
    final response = error.response;

    if (response != null) {
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final detail = data['detail'];

        if (detail != null) {
          return AppException(
            detail.toString(),
            statusCode: response.statusCode,
          );
        }
      }

      return AppException(
        'Server error occurred.',
        statusCode: response.statusCode,
      );
    }

    return AppException(
      'Unable to connect to server.',
    );
  }
}
