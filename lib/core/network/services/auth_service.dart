import 'package:dio/dio.dart';
import '../api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<Response> sendOtp(String phoneNumber) async {
    return await _apiClient.post('/auth/send-otp', data: {
      'phoneNumber': phoneNumber,
    });
  }

  Future<Response> verifyOtp(String phoneNumber, String code) async {
    return await _apiClient.post('/auth/verify-otp', data: {
      'phoneNumber': phoneNumber,
      'code': code,
    });
  }

  Future<Response> register({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    String? email,
  }) async {
    return await _apiClient.post('/auth/register', data: {
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      if (email != null) 'email': email,
    });
  }

  Future<Response> refreshToken(String refreshToken) async {
    return await _apiClient.post('/auth/refresh', data: {
      'refreshToken': refreshToken,
    });
  }
}
