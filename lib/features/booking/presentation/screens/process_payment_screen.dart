import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ceygo_app/core/widgets/gradient_background.dart';
import 'package:ceygo_app/core/widgets/custom_app_bar.dart';
import 'package:ceygo_app/core/network/services/payment_service.dart';
import 'package:ceygo_app/core/widgets/loading_overlay.dart';
import 'package:ceygo_app/core/widgets/error_dialog.dart';
import 'package:ceygo_app/core/widgets/payment_result_dialog.dart';

// Import ProcessPaymentRequest
import 'package:ceygo_app/core/network/services/payment_service.dart' show ProcessPaymentRequest;

class ProcessPaymentScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final String method;
  final double amount;

  const ProcessPaymentScreen({
    super.key,
    required this.bookingId,
    required this.method,
    required this.amount,
  });

  @override
  ConsumerState<ProcessPaymentScreen> createState() => _ProcessPaymentScreenState();
}

class _ProcessPaymentScreenState extends ConsumerState<ProcessPaymentScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _processPayment();
  }

  Future<void> _processPayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final request = ProcessPaymentRequest(
        bookingId: widget.bookingId,
        method: widget.method,
      );

      final service = PaymentService();
      final response = await service.processPayment(request);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        await showPaymentResultDialog(
          context,
          isSuccess: true,
          message: 'Payment processed successfully. Your booking is confirmed!',
          bookingId: widget.bookingId,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        showErrorDialog(
          context,
          title: 'Payment Failed',
          message: e.toString().replaceAll('Exception: ', ''),
          onRetry: () {
            context.pop();
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Processing payment...',
      child: GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: CustomAppBar(
            title: 'Processing Payment',
            useCustomStyle: true,
            leftIcon: Icons.arrow_back,
            onLeftPressed: () => context.pop(),
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
