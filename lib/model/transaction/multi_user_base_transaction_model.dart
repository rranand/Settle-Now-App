import 'package:flutter/foundation.dart';
import 'package:settlenow/model/model_core.dart';

class MultiUserBaseTransactionModel<T extends UserAmountModel>
    extends BaseTransactionModel {
  String category;
  List<T> users;

  MultiUserBaseTransactionModel({
    required super.id,
    required super.amount,
    required super.description,
    required super.createdOn,
    required super.modifiedOn,
    required super.createdBy,
    required this.category,
    required this.users,
  }) : super();

  MultiUserBaseTransactionModel.empty()
    : users = [],
      category = "",
      super.empty();

  @override
  MultiUserBaseTransactionModel<T> copyWith({
    String? id,
    double? amount,
    String? description,
    DateTime? createdOn,
    DateTime? modifiedOn,
    String? createdBy,
    List<T>? users,
    String? category,
  }) {
    return MultiUserBaseTransactionModel<T>(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      createdOn: createdOn ?? this.createdOn,
      createdBy: createdBy ?? this.createdBy,
      modifiedOn: modifiedOn ?? this.modifiedOn,
      category: category ?? this.category,
      users: users ?? this.users,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      ...super.toMap(),
      'category': category,
      'users': users.map((x) => x.toMap()).toList(),
    };
  }

  factory MultiUserBaseTransactionModel.fromMap(
    Map<String, dynamic> map,
    T Function(Map<String, dynamic>) userFromMap,
  ) {
    List<T> allUsers = List<T>.from((map['users']).map((x) => userFromMap(x)));

    final data = BaseTransactionModel.fromMap(map);

    return MultiUserBaseTransactionModel<T>(
      id: data.id,
      amount: data.amount,
      description: data.description,
      createdOn: data.createdOn,
      modifiedOn: data.modifiedOn,
      createdBy: data.createdBy,
      category: map['category'],
      users: allUsers,
    );
  }

  @override
  Map<String, dynamic> toCreateExpenseJson() {
    final allUsers = users.map((e) => e.toMap()).toList();

    return <String, dynamic>{
      ...super.toCreateExpenseJson(),
      "category": category,
      "users": allUsers,
    };
  }

  Map<String, dynamic> toBulkExpenseJson() {
    return <String, dynamic>{
      "amount": super.amount,
      "description": super.description,
      "category": category,
    };
  }

  @override
  Map<String, dynamic> toUpdateExpenseJson() {
    final allUsers = users.map((e) => e.toMap()).toList();

    return <String, dynamic>{
      ...super.toUpdateExpenseJson(),
      "category": category,
      "users": allUsers,
    };
  }

  @override
  String toString() {
    return 'MultiUserBaseTransactionModel(id: $id, description: $description, amount: $amount, createdOn: $createdOn, modifiedOn: $modifiedOn, createdBy: $createdBy, category: $category)';
  }

  @override
  bool operator ==(covariant MultiUserBaseTransactionModel other) {
    if (identical(this, other)) return true;

    return other.hasData == hasData &&
        other.id == id &&
        other.description == description &&
        other.amount == amount &&
        other.createdOn == createdOn &&
        other.modifiedOn == modifiedOn &&
        other.createdBy == createdBy &&
        other.category == category &&
        listEquals(other.users, users);
  }

  @override
  int get hashCode {
    return super.hashCode ^ category.hashCode ^ Object.hashAll(users);
  }
}
