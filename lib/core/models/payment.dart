class Payment {
  final String id;
  final String bookingId;
  final double amount;
  final String method;
  final String status;
  final String? transactionId;
  final String? gatewayTransactionId;
  final Map<String, dynamic>? gatewayResponse;
  final String? refundTransactionId;
  final double? refundAmount;
  final DateTime? refundedAt;
  final String? failureReason;
  final bool isBnpl;
  final bool isEmi;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.method,
    required this.status,
    this.transactionId,
    this.gatewayTransactionId,
    this.gatewayResponse,
    this.refundTransactionId,
    this.refundAmount,
    this.refundedAt,
    this.failureReason,
    required this.isBnpl,
    required this.isEmi,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      amount: (json['amount'] as num).toDouble(),
      method: json['method'] as String,
      status: json['status'] as String,
      transactionId: json['transactionId'] as String?,
      gatewayTransactionId: json['gatewayTransactionId'] as String?,
      gatewayResponse: json['gatewayResponse'] as Map<String, dynamic>?,
      refundTransactionId: json['refundTransactionId'] as String?,
      refundAmount: json['refundAmount'] != null ? (json['refundAmount'] as num).toDouble() : null,
      refundedAt: json['refundedAt'] != null ? DateTime.parse(json['refundedAt'] as String) : null,
      failureReason: json['failureReason'] as String?,
      isBnpl: json['isBnpl'] as bool? ?? false,
      isEmi: json['isEmi'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
