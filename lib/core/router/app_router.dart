import 'package:go_router/go_router.dart';
import 'package:ceygo_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:ceygo_app/features/auth/presentation/screens/login_screen.dart';
import 'package:ceygo_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:ceygo_app/features/auth/presentation/screens/otp_screen.dart';
import 'package:ceygo_app/features/auth/presentation/screens/password_reset_screen.dart';
import 'package:ceygo_app/features/home/presentation/screens/car_details_screen.dart';
import 'package:ceygo_app/features/home/presentation/screens/search_screen.dart';
import 'package:ceygo_app/features/booking/presentation/screens/checkout_screen.dart';
import 'package:ceygo_app/core/widgets/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/otp', builder: (context, state) => const OtpScreen()),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const PasswordResetScreen(),
    ),
    // Main shell with bottom navigation
    GoRoute(path: '/', builder: (context, state) => const MainShell()),
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
  ],
);
