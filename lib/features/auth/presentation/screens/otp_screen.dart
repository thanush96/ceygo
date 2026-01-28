import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:ceygo_app/core/widgets/gradient_background.dart';
import 'package:ceygo_app/core/providers/auth_provider.dart';
import 'package:ceygo_app/core/widgets/error_dialog.dart';
import 'package:ceygo_app/core/widgets/loading_overlay.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get phone from route extra
    final extra = GoRouterState.of(context).extra;
    if (extra is Map<String, dynamic>) {
      _phoneNumber = extra['phone'] as String?;
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6 || _phoneNumber == null) {
      return;
    }

    try {
      await ref.read(authProvider.notifier).verifyOtp(_phoneNumber!, _otpController.text);
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        showErrorDialog(
          context,
          title: 'Verification Failed',
          message: e.toString().replaceAll('Exception: ', ''),
          onRetry: () {
            _otpController.clear();
          },
        );
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_phoneNumber == null) return;
    
    try {
      await ref.read(authProvider.notifier).sendOtp(_phoneNumber!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        showErrorDialog(
          context,
          title: 'Error',
          message: e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return LoadingOverlay(
      isLoading: authState.isLoading,
      message: 'Verifying...',
      child: GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text("Verification"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => context.pop(),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Enter OTP Code",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "We have sent a verification code to $_phoneNumber",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                Pinput(
                  length: 6,
                  controller: _otpController,
                  defaultPinTheme: PinTheme(
                    width: 50,
                    height: 60,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 50,
                    height: 60,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryColor, width: 2),
                    ),
                  ),
                  onCompleted: (pin) => _verifyOtp(),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _otpController.text.length == 6 ? _verifyOtp : null,
                  child: const Text("Verify"),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _resendOtp,
                  child: const Text("Resend OTP"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
