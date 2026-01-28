import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ceygo_app/core/theme/app_theme.dart';

Future<void> showPaymentResultDialog(
  BuildContext context, {
  required bool isSuccess,
  required String message,
  String? bookingId,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? AppTheme.successColor : AppTheme.errorColor,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isSuccess ? 'Payment Successful' : 'Payment Failed',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Text(message),
      actions: [
        if (isSuccess && bookingId != null)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/booking-details', extra: {'id': bookingId});
            },
            child: const Text('View Booking'),
          ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (isSuccess) {
              context.go('/history');
            }
          },
          child: Text(isSuccess ? 'OK' : 'Close'),
        ),
      ],
    ),
  );
}
