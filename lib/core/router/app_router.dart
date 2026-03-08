import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ceygo_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:ceygo_app/features/auth/presentation/screens/login_screen.dart';
import 'package:ceygo_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:ceygo_app/features/auth/presentation/screens/otp_screen.dart';
import 'package:ceygo_app/features/auth/presentation/screens/password_reset_screen.dart';
import 'package:ceygo_app/features/home/presentation/screens/car_details_screen.dart';
import 'package:ceygo_app/features/home/presentation/screens/search_screen.dart';
import 'package:ceygo_app/features/booking/presentation/screens/checkout_screen.dart';
import 'package:ceygo_app/features/booking/presentation/screens/booking_details_screen.dart';
import 'package:ceygo_app/features/booking/presentation/screens/chat_screen.dart';
import 'package:ceygo_app/features/booking/domain/models/booking.dart';
import 'package:ceygo_app/core/widgets/main_shell.dart';
import 'package:ceygo_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:ceygo_app/features/auth/domain/models/auth_state.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authStateNotifier = ValueNotifier<AuthState>(ref.read(authProvider));
  ref.listen<AuthState>(authProvider, (_, next) {
    authStateNotifier.value = next;
  });
  ref.onDispose(authStateNotifier.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authStateNotifier,
    redirect: (context, state) {
      final authState = authStateNotifier.value;
      final isAuthenticated = authState is AuthAuthenticated;
      final isAuthRoute = state.matchedLocation == '/' ||
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/otp' ||
          state.matchedLocation == '/forgot-password';

      // Still loading auth state
      if (authState is AuthInitial) return null;

      // If authenticated and on auth route, go to home
      if (isAuthenticated && isAuthRoute) return '/home';

      // If not authenticated and on protected route, go to login
      if (!isAuthenticated && !isAuthRoute) {
        // Allow unauthenticated access during auth flow states
        if (authState is AuthOtpSent ||
            authState is AuthRegistrationRequired ||
            authState is AuthLoading ||
            authState is AuthError) {
          return null;
        }
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) {
          final phone = state.extra as String?;
          return SignupScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            return OtpScreen(
              phone: extra['phone'] as String?,
              isSignup: extra['isSignup'] as bool? ?? false,
            );
          }
          // Backwards compatible: extra is just a phone string (login flow)
          return OtpScreen(phone: extra as String?);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const PasswordResetScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainShell(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const MainShell(initialIndex: 1),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const MainShell(initialIndex: 2),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const MainShell(initialIndex: 3),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const MainShell(initialIndex: 4),
      ),
      GoRoute(
        path: '/car-details/:id',
        builder: (context, state) =>
            CarDetailsScreen(carId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          return SearchScreen(
            initialSearchQuery: extras?['query'] as String?,
            initialSelectedBrand: extras?['brand'] as String?,
            initialSelectedLocation: extras?['location'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) {
          final car = state.extra as dynamic;
          return CheckoutScreen(car: car);
        },
      ),
      GoRoute(
        path: '/booking-details',
        builder: (context, state) {
          final booking = state.extra as Booking;
          return BookingDetailsScreen(booking: booking);
        },
      ),
      GoRoute(
        path: '/chat/:userId',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          return ChatDetailScreen(
            userId: state.pathParameters['userId']!,
            userName: extras['userName'] as String? ?? 'Owner',
            isOnline: extras['isOnline'] as bool? ?? false,
          );
        },
      ),
    ],
  );
});
