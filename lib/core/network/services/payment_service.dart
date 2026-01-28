import 'package:dio/dio.dart';
import '../api_client.dart';

class ProcessPaymentRequest {
  final String bookingId;
  final String method;
  final String? cardToken;
  final String? walletPin;

  ProcessPaymentRequest({
    required this.bookingId,
    required this.method,
    this.cardToken,
    this.walletPin,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'method': method,
      if (cardToken != null) 'cardToken': cardToken,
      if (walletPin != null) 'walletPin': walletPin,
    };
  }
}

class InitiateBnplRequest {
  final String bookingId;
  final int installmentCount;
  final String? provider;

  InitiateBnplRequest({
    required this.bookingId,
    required this.installmentCount,
    this.provider,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'installmentCount': installmentCount,
      if (provider != null) 'provider': provider,
    };
  }
}

class CalculateEmiRequest {
  final double amount;
  final String bankName;
  final int tenureMonths;

  CalculateEmiRequest({
    required this.amount,
    required this.bankName,
    required this.tenureMonths,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'bankName': bankName,
      'tenureMonths': tenureMonths,
    };
  }
}

class InitiateEmiRequest {
  final String bookingId;
  final String bankName;
  final int tenureMonths;

  InitiateEmiRequest({
    required this.bookingId,
    required this.bankName,
    required this.tenureMonths,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'bankName': bankName,
      'tenureMonths': tenureMonths,
    };
  }
}

class PaymentService {
  final ApiClient _apiClient = ApiClient();

  Future<Response> processPayment(ProcessPaymentRequest request) async {
    return await _apiClient.post('/payments/process', data: request.toJson());
  }

  Future<Response> checkBnplEligibility(double amount) async {
    return await _apiClient.post('/payments/bnpl/check-eligibility', queryParameters: {'amount': amount});
  }

  Future<Response> initiateBnpl(InitiateBnplRequest request) async {
    return await _apiClient.post('/payments/bnpl/initiate', data: request.toJson());
  }

  Future<Response> checkEmiEligibility(double amount) async {
    return await _apiClient.post('/payments/emi/check-eligibility', queryParameters: {'amount': amount});
  }

  Future<Response> calculateEmi(CalculateEmiRequest request) async {
    return await _apiClient.post('/payments/emi/calculate', data: request.toJson());
  }

  Future<Response> initiateEmi(InitiateEmiRequest request) async {
    return await _apiClient.post('/payments/emi/initiate', data: request.toJson());
  }

  Future<Response> getPaymentDetails(String id) async {
    return await _apiClient.get('/payments/$id');
  }

  Future<Response> getUserBnplPlans() async {
    return await _apiClient.get('/payments/bnpl/plans');
  }

  Future<Response> getUserEmiPlans() async {
    return await _apiClient.get('/payments/emi/plans');
  }
}
