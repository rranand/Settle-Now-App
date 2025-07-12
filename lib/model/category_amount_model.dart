class CategoryAmountModel {
  final String category;
  final double amount;

  CategoryAmountModel({required this.category, required this.amount});

  @override
  bool operator ==(covariant CategoryAmountModel other) {
    if (identical(this, other)) return true;

    return other.category == category && other.amount == amount;
  }

  @override
  int get hashCode {
    return category.hashCode ^ amount.hashCode;
  }
}
