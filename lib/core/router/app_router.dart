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
import 'package:ceygo_app/features/booking/presentation/screens/payment_method_screen.dart';
import 'package:ceygo_app/features/booking/presentation/screens/bnpl_selection_screen.dart';
import 'package:ceygo_app/features/booking/presentation/screens/emi_selection_screen.dart';
import 'package:ceygo_app/features/booking/presentation/screens/card_payment_screen.dart';
import 'package:ceygo_app/features/booking/presentation/screens/process_payment_screen.dart';
import 'package:ceygo_app/features/booking/domain/models/booking.dart';
import 'package:ceygo_app/core/widgets/main_shell.dart';
import 'package:ceygo_app/core/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = isAuthenticated;
      final isGoingToLogin = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/otp' ||
          state.matchedLocation == '/';

      // If not logged in and trying to access protected route
      if (!isLoggedIn && !isGoingToLogin) {
        return '/login';
      }

      // If logged in and trying to access auth pages
      if (isLoggedIn && isGoingToLogin && state.matchedLocation != '/') {
        return '/home';
      }

      return null;
    },
    routes: [
    GoRoute(path: '/', builder: (context, state) => const OnboardingScreen()),
    // GoRoute(path: '/', builder: (context, state) => const OnboardingScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/otp', builder: (context, state) => const OtpScreen()),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const PasswordResetScreen(),
    ),
    // Main shell with bottom navigation
    // GoRoute(path: '/', builder: (context, state) => const MainShell()),
    GoRoute(path: '/home', builder: (context, state) => const MainShell()),
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
      builder:
          (context, state) =>
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
        final extra = state.extra;
        if (extra is Booking) {
          return BookingDetailsScreen(booking: extra);
        } else if (extra is Map<String, dynamic> && extra['id'] != null) {
          // Fetch booking by ID - for now return placeholder
          // In production, you'd fetch it here
          return const Scaffold(
            body: Center(child: Text('Booking not found')),
          );
        }
        return const Scaffold(
          body: Center(child: Text('Invalid booking')),
        );
      },
    ),
    GoRoute(
      path: '/payment-method',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return PaymentMethodScreen(
          bookingId: extra['bookingId'] as String,
          amount: (extra['amount'] as num).toDouble(),
        );
      },
    ),
    GoRoute(
      path: '/bnpl-selection',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return BnplSelectionScreen(
          bookingId: extra['bookingId'] as String,
          amount: (extra['amount'] as num).toDouble(),
        );
      },
    ),
    GoRoute(
      path: '/emi-selection',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return EmiSelectionScreen(
          bookingId: extra['bookingId'] as String,
          amount: (extra['amount'] as num).toDouble(),
        );
      },
    ),
    GoRoute(
      path: '/card-payment',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return CardPaymentScreen(
          bookingId: extra['bookingId'] as String,
          amount: (extra['amount'] as num).toDouble(),
        );
      },
    ),
    GoRoute(
      path: '/process-payment',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return ProcessPaymentScreen(
          bookingId: extra['bookingId'] as String,
          method: extra['method'] as String,
          amount: (extra['amount'] as num).toDouble(),
        );
      },
    ),
  ],
  );
});
