enum EmiInstallmentStatus {
  pending,
  paid,
  overdue,
  failed,
}

class EmiInstallment {
  final String id;
  final String planId;
  final int installmentNumber;
  final double principalAmount;
  final double interestAmount;
  final double totalAmount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final EmiInstallmentStatus status;
  final String? paymentId;

  EmiInstallment({
    required this.id,
    required this.planId,
    required this.installmentNumber,
    required this.principalAmount,
    required this.interestAmount,
    required this.totalAmount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    this.paymentId,
  });

  factory EmiInstallment.fromJson(Map<String, dynamic> json) {
    return EmiInstallment(
      id: json['id'] as String,
      planId: json['planId'] as String,
      installmentNumber: json['installmentNumber'] as int,
      principalAmount: (json['principalAmount'] as num).toDouble(),
      interestAmount: (json['interestAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      paidDate: json['paidDate'] != null
          ? DateTime.parse(json['paidDate'] as String)
          : null,
      status: _parseStatus(json['status'] as String),
      paymentId: json['paymentId'] as String?,
    );
  }

  static EmiInstallmentStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return EmiInstallmentStatus.pending;
      case 'paid':
        return EmiInstallmentStatus.paid;
      case 'overdue':
        return EmiInstallmentStatus.overdue;
      case 'failed':
        return EmiInstallmentStatus.failed;
      default:
        return EmiInstallmentStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planId': planId,
      'installmentNumber': installmentNumber,
      'principalAmount': principalAmount,
      'interestAmount': interestAmount,
      'totalAmount': totalAmount,
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'status': status.name,
      'paymentId': paymentId,
    };
  }
}
