class WalletTransaction {
  final String id;
  final double amount;
  final String type; // 'credit' or 'debit'
  final String status;
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
      type: json['type'] as String,
      status: json['status'] as String,
      description: json['description'] as String,
      reference: json['reference'] as String?,
      bookingId: json['bookingId'] as String?,
      balanceBefore: (json['balanceBefore'] as num).toDouble(),
      balanceAfter: (json['balanceAfter'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class Wallet {
  final String id;
  final double balance;
  final double totalEarned;
  final double totalSpent;
  final bool isActive;
  final List<WalletTransaction>? transactions;

  Wallet({
    required this.id,
    required this.balance,
    required this.totalEarned,
    required this.totalSpent,
    required this.isActive,
    this.transactions,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as String,
      balance: (json['balance'] as num).toDouble(),
      totalEarned: (json['totalEarned'] as num).toDouble(),
      totalSpent: (json['totalSpent'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      transactions: json['transactions'] != null
          ? (json['transactions'] as List)
              .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}
