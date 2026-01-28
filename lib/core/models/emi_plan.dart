class EmiInstallment {
  final String id;
  final int installmentNumber;
  final double principalAmount;
  final double interestAmount;
  final double totalAmount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String status;

  EmiInstallment({
    required this.id,
    required this.installmentNumber,
    required this.principalAmount,
    required this.interestAmount,
    required this.totalAmount,
    required this.dueDate,
    this.paidDate,
    required this.status,
  });

  factory EmiInstallment.fromJson(Map<String, dynamic> json) {
    return EmiInstallment(
      id: json['id'] as String,
      installmentNumber: json['installmentNumber'] as int,
      principalAmount: (json['principalAmount'] as num).toDouble(),
      interestAmount: (json['interestAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate'] as String) : null,
      status: json['status'] as String,
    );
  }
}

class EmiPlan {
  final String id;
  final String paymentId;
  final String bookingId;
  final double principalAmount;
  final double interestRate;
  final int tenureMonths;
  final double emiAmount;
  final double totalAmount;
  final DateTime firstPaymentDate;
  final String status;
  final String? bankName;
  final List<EmiInstallment>? installments;

  EmiPlan({
    required this.id,
    required this.paymentId,
    required this.bookingId,
    required this.principalAmount,
    required this.interestRate,
    required this.tenureMonths,
    required this.emiAmount,
    required this.totalAmount,
    required this.firstPaymentDate,
    required this.status,
    this.bankName,
    this.installments,
  });

  factory EmiPlan.fromJson(Map<String, dynamic> json) {
    return EmiPlan(
      id: json['id'] as String,
      paymentId: json['paymentId'] as String,
      bookingId: json['bookingId'] as String,
      principalAmount: (json['principalAmount'] as num).toDouble(),
      interestRate: (json['interestRate'] as num).toDouble(),
      tenureMonths: json['tenureMonths'] as int,
      emiAmount: (json['emiAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      firstPaymentDate: DateTime.parse(json['firstPaymentDate'] as String),
      status: json['status'] as String,
      bankName: json['bankName'] as String?,
      installments: json['installments'] != null
          ? (json['installments'] as List)
              .map((e) => EmiInstallment.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}
