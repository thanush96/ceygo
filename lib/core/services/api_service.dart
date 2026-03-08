import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceygo_app/core/config/api_config.dart';
import 'package:ceygo_app/core/services/storage_service.dart';

final storageServiceProvider = Provider((ref) => StorageService());

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(AuthInterceptor(dio: dio, storage: storage));
  return dio;
});

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final StorageService storage;
  bool _isRefreshing = false;

  AuthInterceptor({required this.dio, required this.storage});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await storage.getRefreshToken();
        if (refreshToken == null) {
          await storage.clearAll();
          _isRefreshing = false;
          return handler.next(err);
        }

        final freshDio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            headers: {'Content-Type': 'application/json'},
          ),
        );

        final response = await freshDio.post(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );

        final newAccessToken = response.data['accessToken'] as String;
        final newRefreshToken = response.data['refreshToken'] as String;
        await storage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        // Retry the original request
        err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await freshDio.fetch(err.requestOptions);
        _isRefreshing = false;
        return handler.resolve(retryResponse);
      } catch (e) {
        _isRefreshing = false;
        await storage.clearAll();
        return handler.next(err);
      }
    }
    handler.next(err);
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  factory ApiException.fromDioError(DioException error) {
    final data = error.response?.data;
    String message = 'Something went wrong';
    if (data is Map && data.containsKey('message')) {
      final msg = data['message'];
      message = msg is List ? msg.first : msg.toString();
    } else if (error.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout. Please check your internet.';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'Cannot connect to server. Please try again.';
    }
    return ApiException(message, statusCode: error.response?.statusCode);
  }

  @override
  String toString() => message;
}
