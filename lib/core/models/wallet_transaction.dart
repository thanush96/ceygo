enum TransactionType {
  credit,
  debit,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

class WalletTransaction {
  final String id;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final String description;
  final String? reference;
  final String? bookingId;
  final double balanceBefore;
  final double balanceAfter;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    required this.description,
    this.reference,
    this.bookingId,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: _parseTransactionType(json['type'] as String),
      status: _parseTransactionStatus(json['status'] as String),
      description: json['description'] as String,
      reference: json['reference'] as String?,
      bookingId: json['bookingId'] as String?,
      balanceBefore: (json['balanceBefore'] as num).toDouble(),
      balanceAfter: (json['balanceAfter'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static TransactionType _parseTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'credit':
        return TransactionType.credit;
      case 'debit':
        return TransactionType.debit;
      default:
        return TransactionType.debit;
    }
  }

  static TransactionStatus _parseTransactionStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TransactionStatus.pending;
      case 'completed':
        return TransactionStatus.completed;
      case 'failed':
        return TransactionStatus.failed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name,
      'status': status.name,
      'description': description,
      'reference': reference,
      'bookingId': bookingId,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
