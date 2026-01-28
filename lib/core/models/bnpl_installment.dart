enum BnplInstallmentStatus {
  pending,
  paid,
  overdue,
  failed,
}

class BnplInstallment {
  final String id;
  final String planId;
  final int installmentNumber;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final BnplInstallmentStatus status;
  final String? paymentId;

  BnplInstallment({
    required this.id,
    required this.planId,
    required this.installmentNumber,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    this.paymentId,
  });

  factory BnplInstallment.fromJson(Map<String, dynamic> json) {
    return BnplInstallment(
      id: json['id'] as String,
      planId: json['planId'] as String,
      installmentNumber: json['installmentNumber'] as int,
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      paidDate: json['paidDate'] != null
          ? DateTime.parse(json['paidDate'] as String)
          : null,
      status: _parseStatus(json['status'] as String),
      paymentId: json['paymentId'] as String?,
    );
  }

  static BnplInstallmentStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BnplInstallmentStatus.pending;
      case 'paid':
        return BnplInstallmentStatus.paid;
      case 'overdue':
        return BnplInstallmentStatus.overdue;
      case 'failed':
        return BnplInstallmentStatus.failed;
      default:
        return BnplInstallmentStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planId': planId,
      'installmentNumber': installmentNumber,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'status': status.name,
      'paymentId': paymentId,
    };
  }
}
