class BulkTransactionModel {
  final double amount;
  final String category;
  final String description;

  BulkTransactionModel({
    required this.amount,
    required this.category,
    required this.description,
  });

  @override
  bool operator ==(covariant BulkTransactionModel other) {
    if (identical(this, other)) return true;

    return other.category == category &&
        other.amount == amount &&
        other.description == description;
  }

  @override
  int get hashCode {
    return category.hashCode ^ amount.hashCode ^ description.hashCode;
  }

  BulkTransactionModel copyWith({
    double? amount,
    String? category,
    String? description,
  }) {
    return BulkTransactionModel(
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
    );
  }
}
