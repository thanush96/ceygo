import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ceygo_app/core/models/user.dart';
import 'package:ceygo_app/core/models/auth_response.dart';
import 'package:ceygo_app/core/network/services/auth_service.dart';
import 'package:ceygo_app/core/network/api_exception.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => user != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();

  AuthNotifier() : super(AuthState()) {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token != null) {
        // Token exists, but we need to verify it's valid
        // For now, we'll just check if token exists
        // In production, you might want to call /users/profile to verify
        state = state.copyWith(isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendOtp(String phoneNumber) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _authService.sendOtp(phoneNumber);
      state = state.copyWith(isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> verifyOtp(String phoneNumber, String code) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final response = await _authService.verifyOtp(phoneNumber, code);
      final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
      
      // Store tokens
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', authResponse.accessToken);
      await prefs.setString('refresh_token', authResponse.refreshToken);
      
      // Update state
      state = state.copyWith(
        user: authResponse.user,
        isLoading: false,
        error: null,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> register({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    String? email,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _authService.register(
        phoneNumber: phoneNumber,
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
      state = state.copyWith(isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    state = AuthState();
  }

  Future<void> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      if (refreshToken == null) {
        await logout();
        return;
      }

      final response = await _authService.refreshToken(refreshToken);
      final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
      
      await prefs.setString('access_token', authResponse.accessToken);
      await prefs.setString('refresh_token', authResponse.refreshToken);
      
      state = state.copyWith(user: authResponse.user);
    } catch (e) {
      // Refresh failed, logout user
      await logout();
      rethrow;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});
