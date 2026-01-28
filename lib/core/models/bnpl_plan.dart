class BnplInstallment {
  final String id;
  final int installmentNumber;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String status;

  BnplInstallment({
    required this.id,
    required this.installmentNumber,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
  });

  factory BnplInstallment.fromJson(Map<String, dynamic> json) {
    return BnplInstallment(
      id: json['id'] as String,
      installmentNumber: json['installmentNumber'] as int,
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate'] as String) : null,
      status: json['status'] as String,
    );
  }
}

class BnplPlan {
  final String id;
  final String paymentId;
  final String bookingId;
  final double totalAmount;
  final int installmentCount;
  final double installmentAmount;
  final double interestRate;
  final DateTime firstPaymentDate;
  final DateTime lastPaymentDate;
  final String status;
  final String? provider;
  final List<BnplInstallment>? installments;

  BnplPlan({
    required this.id,
    required this.paymentId,
    required this.bookingId,
    required this.totalAmount,
    required this.installmentCount,
    required this.installmentAmount,
    required this.interestRate,
    required this.firstPaymentDate,
    required this.lastPaymentDate,
    required this.status,
    this.provider,
    this.installments,
  });

  factory BnplPlan.fromJson(Map<String, dynamic> json) {
    return BnplPlan(
      id: json['id'] as String,
      paymentId: json['paymentId'] as String,
      bookingId: json['bookingId'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      installmentCount: json['installmentCount'] as int,
      installmentAmount: (json['installmentAmount'] as num).toDouble(),
      interestRate: (json['interestRate'] as num).toDouble(),
      firstPaymentDate: DateTime.parse(json['firstPaymentDate'] as String),
      lastPaymentDate: DateTime.parse(json['lastPaymentDate'] as String),
      status: json['status'] as String,
      provider: json['provider'] as String?,
      installments: json['installments'] != null
          ? (json['installments'] as List)
              .map((e) => BnplInstallment.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}
