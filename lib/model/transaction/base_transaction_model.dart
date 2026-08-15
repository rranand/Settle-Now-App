class BaseTransactionModel {
  bool hasData = true;
  String id;
  String description;
  double amount;
  DateTime createdOn;
  DateTime modifiedOn;
  String createdBy;

  BaseTransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.createdOn,
    required this.modifiedOn,
    required this.createdBy,
  });

  BaseTransactionModel.empty({this.hasData = false})
    : id = '',
      description = '',
      amount = 0.0,
      createdOn = DateTime.now(),
      modifiedOn = DateTime.now(),
      createdBy = '';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'amount': amount,
      'description': description,
      'created_by': createdBy,
      'created_on': createdOn.toUtc().toIso8601String(),
      'modified_on': modifiedOn.toUtc().toIso8601String(),
    };
  }

  factory BaseTransactionModel.fromMap(Map<String, dynamic> map) {
    return BaseTransactionModel(
      id: map['id'],
      description: map['description'],
      amount: double.parse(map['amount'].toString()),
      createdBy: map['created_by'] ?? "",
      createdOn: DateTime.parse(map['created_on']).toLocal(),
      modifiedOn: DateTime.parse(map['modified_on']).toLocal(),
    );
  }

  BaseTransactionModel copyWith({
    String? id,
    String? description,
    double? amount,
    DateTime? createdOn,
    DateTime? modifiedOn,
    String? createdBy,
  }) {
    return BaseTransactionModel(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      createdOn: createdOn ?? this.createdOn,
      modifiedOn: modifiedOn ?? this.modifiedOn,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  Map<String, dynamic> toCreateExpenseJson() {
    return {
      "amount": amount,
      "description": description,
      "created_on": createdOn.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateExpenseJson() {
    return {"id": id, "amount": amount, "description": description};
  }

  @override
  String toString() {
    return 'BaseTransactionModel(hasData: $hasData, id: $id, description: $description, amount: $amount, createdOn: $createdOn, modifiedOn: $modifiedOn, createdBy: $createdBy)';
  }

  @override
  bool operator ==(covariant BaseTransactionModel other) {
    if (identical(this, other)) return true;

    return other.hasData == hasData &&
        other.id == id &&
        other.description == description &&
        other.amount == amount &&
        other.createdOn == createdOn &&
        other.createdBy == createdBy;
  }

  @override
  int get hashCode {
    return hasData.hashCode ^
        id.hashCode ^
        description.hashCode ^
        amount.hashCode ^
        createdBy.hashCode;
  }
}
