import 'package:go_router/go_router.dart';
import 'package:ceygo_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:ceygo_app/features/auth/presentation/screens/login_screen.dart';
import 'package:ceygo_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:ceygo_app/features/auth/presentation/screens/otp_screen.dart';
import 'package:ceygo_app/features/auth/presentation/screens/password_reset_screen.dart';
import 'package:ceygo_app/features/home/presentation/screens/car_details_screen.dart';
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
      path: '/car-details/:id',
      builder:
          (context, state) =>
              CarDetailsScreen(carId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
  ],
);
