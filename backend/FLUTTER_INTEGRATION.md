# Flutter Integration Guide

## API Base Configuration

```dart
// lib/core/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'http://your-api-url/api/v1';
  static const String apiDocs = 'http://your-api-url/api/docs';
  static const Duration timeout = Duration(seconds: 30);
}
```

## Error Handling

```dart
// lib/core/exceptions/api_exception.dart
class ApiException implements Exception {
  final String code;
  final String message;
  
  ApiException({required this.code, required this.message});
  
  String get userMessage {
    const messages = {
      'OTP_EXPIRED': 'OTP has expired. Please request a new one.',
      'OTP_INVALID': 'Invalid OTP. Please check and try again.',
      'OTP_RATE_LIMIT': 'Too many OTP requests. Please wait before trying again.',
      'BOOKING_CONFLICT': 'This vehicle is already booked for the selected dates.',
      'VEHICLE_UNAVAILABLE': 'Vehicle is not available for booking.',
      'PAYMENT_FAILED': 'Payment failed. Please try again or use a different method.',
      'INSUFFICIENT_BALANCE': 'Insufficient wallet balance. Please top up your wallet.',
      'NETWORK_ERROR': 'Network error. Please check your connection.',
    };
    
    return messages[code] ?? message;
  }
}
```

## API Response Models

```dart
// lib/core/models/api_response.dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final ApiError? error;
  final Map<String, dynamic>? meta;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.meta,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : null,
      error: json['error'] != null ? ApiError.fromJson(json['error']) : null,
      meta: json['meta'],
    );
  }
}

class ApiError {
  final String code;
  final String message;
  final String timestamp;

  ApiError({
    required this.code,
    required this.message,
    required this.timestamp,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'],
      message: json['message'],
      timestamp: json['timestamp'],
    );
  }
}
```

## Required Alerts Implementation

```dart
// lib/core/utils/alert_helper.dart
class AlertHelper {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onAction();
              },
              child: Text(actionLabel),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

## Token Management

```dart
// lib/core/auth/token_manager.dart
class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }
  
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }
  
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }
  
  static Future<bool> isTokenExpired(String token) async {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      
      final payload = parts[1];
      final normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64.decode(normalized));
      final json = jsonDecode(decoded);
      
      final exp = json['exp'] as int;
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      return true;
    }
  }
}
```

## HTTP Client Setup

```dart
// lib/core/api/http_client.dart
class HttpClient {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: ApiConfig.timeout,
    receiveTimeout: ApiConfig.timeout,
  ));

  HttpClient() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenManager.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Handle token refresh
          _handleTokenRefresh(error, handler);
        } else {
          handler.next(error);
        }
      },
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException error) {
    if (error.response != null) {
      final errorData = error.response!.data;
      if (errorData is Map && errorData['error'] != null) {
        return ApiException(
          code: errorData['error']['code'] ?? 'UNKNOWN_ERROR',
          message: errorData['error']['message'] ?? 'An error occurred',
        );
      }
    }
    
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return ApiException(code: 'TIMEOUT', message: 'Request timeout');
    }
    
    if (error.type == DioExceptionType.connectionError) {
      return ApiException(code: 'NETWORK_ERROR', message: 'Network error');
    }
    
    return ApiException(code: 'UNKNOWN_ERROR', message: 'An unexpected error occurred');
  }

  Future<void> _handleTokenRefresh(DioException error, ErrorInterceptorHandler handler) async {
    // Implement token refresh logic
    final refreshToken = await TokenManager.getRefreshToken();
    if (refreshToken != null) {
      // Call refresh endpoint
      // Update tokens
      // Retry original request
    } else {
      // Redirect to login
      handler.next(error);
    }
  }
}
```

## Usage Example

```dart
// In your screen/widget
final httpClient = HttpClient();

try {
  final response = await httpClient.post('/auth/verify-otp', data: {
    'phoneNumber': phoneNumber,
    'code': otpCode,
  });
  
  final apiResponse = ApiResponse.fromJson(response.data, (data) => AuthResponse.fromJson(data));
  
  if (apiResponse.success && apiResponse.data != null) {
    await TokenManager.saveTokens(
      apiResponse.data!.accessToken,
      apiResponse.data!.refreshToken,
    );
    // Navigate to home
  }
} on ApiException catch (e) {
  AlertHelper.showError(context, e.userMessage);
} catch (e) {
  AlertHelper.showError(context, 'An unexpected error occurred');
}
```
