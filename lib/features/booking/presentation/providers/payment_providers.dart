import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceygo_app/core/network/services/payment_service.dart';
import 'package:ceygo_app/core/models/payment.dart';
import 'package:ceygo_app/core/models/bnpl_plan.dart';
import 'package:ceygo_app/core/models/emi_plan.dart';

// Re-export request classes for convenience
export 'package:ceygo_app/core/network/services/payment_service.dart'
    show ProcessPaymentRequest, InitiateBnplRequest, CalculateEmiRequest, InitiateEmiRequest;

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

// Selected payment method
final selectedPaymentMethodProvider = StateProvider<String?>((ref) => null);

// BNPL Eligibility
final bnplEligibilityProvider = FutureProvider.family<Map<String, dynamic>, double>((ref, amount) async {
  final service = ref.read(paymentServiceProvider);
  final response = await service.checkBnplEligibility(amount);
  return response.data as Map<String, dynamic>;
});

// EMI Eligibility
final emiEligibilityProvider = FutureProvider.family<Map<String, dynamic>, double>((ref, amount) async {
  final service = ref.read(paymentServiceProvider);
  final response = await service.checkEmiEligibility(amount);
  return response.data as Map<String, dynamic>;
});

// Process payment
final processPaymentProvider = FutureProvider.family<Payment, ProcessPaymentRequest>((ref, request) async {
  final service = ref.read(paymentServiceProvider);
  final response = await service.processPayment(request);
  return Payment.fromJson(response.data as Map<String, dynamic>);
});

// Initiate BNPL
final initiateBnplProvider = FutureProvider.family<BnplPlan, InitiateBnplRequest>((ref, request) async {
  final service = ref.read(paymentServiceProvider);
  final response = await service.initiateBnpl(request);
  return BnplPlan.fromJson(response.data as Map<String, dynamic>);
});

// Calculate EMI
final calculateEmiProvider = FutureProvider.family<Map<String, dynamic>, CalculateEmiRequest>((ref, request) async {
  final service = ref.read(paymentServiceProvider);
  final response = await service.calculateEmi(request);
  return response.data as Map<String, dynamic>;
});

// Initiate EMI
final initiateEmiProvider = FutureProvider.family<EmiPlan, InitiateEmiRequest>((ref, request) async {
  final service = ref.read(paymentServiceProvider);
  final response = await service.initiateEmi(request);
  return EmiPlan.fromJson(response.data as Map<String, dynamic>);
});
