import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceygo_app/features/auth/data/auth_repository.dart';
import 'package:ceygo_app/features/auth/domain/models/auth_state.dart';
import 'package:ceygo_app/features/auth/domain/models/user_model.dart';
import 'package:ceygo_app/core/services/api_service.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);

// Convenient provider to check if user is logged in
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) is AuthAuthenticated;
});

// Convenient provider to get current user
final currentUserProvider = Provider<UserModel?>((ref) {
  final state = ref.watch(authProvider);
  if (state is AuthAuthenticated) return state.user;
  return null;
});

class AuthNotifier extends Notifier<AuthState> {
  late AuthRepository _repository;

  /// Holds registration form data between signup OTP request and verification
  Map<String, String>? _pendingRegistration;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    _tryRestoreSession();
    return const AuthInitial();
  }

  Future<void> _tryRestoreSession() async {
    final user = await _repository.tryRestoreSession();
    if (user != null) {
      state = AuthAuthenticated(user);
    } else {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> refreshUser() async {
    final user = await _repository.tryRestoreSession();
    if (user != null) {
      state = AuthAuthenticated(user);
    }
  }

  void updateUser(UserModel user) {
    state = AuthAuthenticated(user);
  }

  /// Request OTP for login (existing user)
  Future<void> requestOtp(String phone) async {
    state = const AuthLoading();
    try {
      await _repository.requestOtp(phone);
      state = AuthOtpSent(phone);
    } on ApiException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError('Failed to send OTP. Please try again.');
    }
  }

  /// Verify OTP for login
  Future<void> verifyOtp({required String phone, required String otp}) async {
    state = const AuthLoading();
    try {
      final result = await _repository.verifyOtp(phone: phone, otp: otp);
      if (result.isNewUser) {
        state = AuthRegistrationRequired(result.phone);
      } else {
        state = AuthAuthenticated(result.user!);
      }
    } on ApiException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError('OTP verification failed. Please try again.');
    }
  }

  /// Step 1 of signup: Store form data and send OTP
  Future<void> requestSignupOtp({
    required String name,
    required String email,
    required String phone,
    required String nationality,
    required String idType,
    required String idNumber,
    required String licenseNo,
    String role = 'renter',
  }) async {
    state = const AuthLoading();
    try {
      await _repository.requestSignupOtp(phone);
      // Store registration data for after OTP verification
      _pendingRegistration = {
        'name': name,
        'email': email,
        'phone': phone,
        'nationality': nationality,
        'idType': idType,
        'idNumber': idNumber,
        'licenseNo': licenseNo,
        'role': role,
      };
      state = AuthOtpSent(phone);
    } on ApiException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError('Failed to send OTP. Please try again.');
    }
  }

  /// Step 2 of signup: Verify OTP and register user
  Future<void> verifySignupOtp({required String otp}) async {
    final data = _pendingRegistration;
    if (data == null) {
      state = const AuthError('Registration data lost. Please try again.');
      return;
    }

    state = const AuthLoading();
    try {
      final user = await _repository.register(
        name: data['name']!,
        email: data['email']!,
        phone: data['phone']!,
        nationality: data['nationality']!,
        idType: data['idType']!,
        idNumber: data['idNumber']!,
        licenseNo: data['licenseNo']!,
        otp: otp,
        role: data['role'] ?? 'renter',
      );
      _pendingRegistration = null;
      state = AuthAuthenticated(user);
    } on ApiException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError('Registration failed. Please try again.');
    }
  }

  /// Whether we're in the signup OTP flow (for OTP screen to know)
  bool get isSignupFlow => _pendingRegistration != null;

  /// Logout
  Future<void> logout() async {
    await _repository.logout();
    _pendingRegistration = null;
    state = const AuthUnauthenticated();
  }

  /// Reset error state to allow retry
  void resetError() {
    state = const AuthUnauthenticated();
  }
}
