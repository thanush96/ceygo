import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceygo_app/core/services/api_service.dart';
import 'package:ceygo_app/core/services/storage_service.dart';
import 'package:ceygo_app/features/auth/domain/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.watch(dioProvider),
    storage: ref.watch(storageServiceProvider),
  );
});

class AuthRepository {
  final Dio _dio;
  final StorageService _storage;

  AuthRepository({required Dio dio, required StorageService storage})
    : _dio = dio,
      _storage = storage;

  /// Step 1: Request OTP for phone login
  Future<void> requestOtp(String phone) async {
    try {
      await _dio.post('/auth/login', data: {'phone': phone});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Request OTP for signup (new user)
  Future<void> requestSignupOtp(String phone) async {
    try {
      await _dio.post('/auth/signup/send-otp', data: {'phone': phone});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Step 2: Verify OTP - returns {isNewUser, phone} or {isNewUser, user, tokens}
  Future<OtpVerificationResult> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp',
        data: {'phone': phone, 'otp': otp},
      );

      final data = response.data as Map<String, dynamic>;
      final isNewUser = data['isNewUser'] as bool;

      if (isNewUser) {
        return OtpVerificationResult(
          isNewUser: true,
          phone: data['phone'] as String,
        );
      }

      // Existing user - save tokens and user
      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

      await _storage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      await _storage.saveUserData(user.toJsonString());

      return OtpVerificationResult(
        isNewUser: false,
        phone: phone,
        user: user,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Step 3: Register new user after OTP verification
  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String nationality,
    required String idType,
    required String idNumber,
    required String licenseNo,
    required String otp,
    String role = 'renter',
    String? profilePic,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'nationality': nationality,
        'idType': idType,
        'idNumber': idNumber,
        'licenseNo': licenseNo,
        'otp': otp,
        'role': role,
        if (profilePic != null) 'profilePic': profilePic,
      });

      final data = response.data as Map<String, dynamic>;
      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

      await _storage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      await _storage.saveUserData(user.toJsonString());

      return user;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Try to restore session from stored tokens
  Future<UserModel?> tryRestoreSession() async {
    final token = await _storage.getAccessToken();
    if (token == null) return null;

    final userData = await _storage.getUserData();
    if (userData == null) return null;

    try {
      return UserModel.fromJsonString(userData);
    } catch (_) {
      await _storage.clearAll();
      return null;
    }
  }

  /// Logout - clear all stored data
  Future<void> logout() async {
    await _storage.clearAll();
  }
}

class OtpVerificationResult {
  final bool isNewUser;
  final String phone;
  final UserModel? user;

  OtpVerificationResult({
    required this.isNewUser,
    required this.phone,
    this.user,
  });
}
