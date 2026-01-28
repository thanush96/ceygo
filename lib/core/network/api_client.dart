import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_exception.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:3000/api/v1';
  late Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response != null) {
          final statusCode = error.response!.statusCode;
          final data = error.response!.data;
          String message = 'An error occurred';

          if (data is Map<String, dynamic>) {
            message = data['message'] ?? 
                     data['error'] ?? 
                     error.response?.statusMessage ?? 
                     'An error occurred';
          } else if (data is String) {
            message = data;
          }

          ApiException exception;
          switch (statusCode) {
            case 400:
              exception = BadRequestException(message, data: data);
              break;
            case 401:
              exception = UnauthorizedException(message);
              break;
            case 404:
              exception = NotFoundException(message);
              break;
            case 500:
            case 502:
            case 503:
              exception = ServerException(message);
              break;
            default:
              exception = ApiException(message, statusCode: statusCode, data: data);
          }
          return handler.reject(DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            type: DioExceptionType.badResponse,
            error: exception,
          ));
        } else if (error.type == DioExceptionType.connectionTimeout ||
                   error.type == DioExceptionType.receiveTimeout ||
                   error.type == DioExceptionType.sendTimeout) {
          return handler.reject(DioException(
            requestOptions: error.requestOptions,
            type: error.type,
            error: NetworkException('Connection timeout. Please check your internet connection.'),
          ));
        } else if (error.type == DioExceptionType.connectionError) {
          return handler.reject(DioException(
            requestOptions: error.requestOptions,
            type: error.type,
            error: NetworkException('No internet connection. Please check your network.'),
          ));
        }
        return handler.reject(error);
      },
    ));
  }

  Dio get dio => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException error) {
    if (error.error is ApiException) {
      return error.error as ApiException;
    }
    return NetworkException('Network error: ${error.message}');
  }
}
