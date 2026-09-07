class CategoryAmountModel {
  final String category;
  final double amount;

  CategoryAmountModel({required this.category, required this.amount});

  factory CategoryAmountModel.fromMap(Map<String, dynamic> map) {
    return CategoryAmountModel(
      category: map['category'],
      amount: double.parse(map['amount'].toString()),
    );
  }

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
