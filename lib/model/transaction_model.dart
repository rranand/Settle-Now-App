// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/model/new_transaction_model.dart';
import 'package:settlenow_v2/model/personal_expense_transaction_model.dart';
import 'package:settlenow_v2/model/user_amount_model.dart';

class TransactionModel {
  bool hasData = true;
  String id = "";
  String description = "";
  double amount = 0;
  String category = "";
  UserAmountModel createdBy = UserAmountModel.empty();
  List<UserAmountModel> users = [];
  DateTime createdOn = DateTime.now();
  DateTime modifiedOn = DateTime.now();

  TransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.users,
    required this.createdBy,
    required this.createdOn,
    required this.modifiedOn,
  });

  TransactionModel.empty({this.hasData = false});

  TransactionModel copyWith({
    String? id,
    String? description,
    double? amount,
    String? category,
    List<UserAmountModel>? users,
    UserAmountModel? createdBy,
    DateTime? createdOn,
    DateTime? modifiedOn,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      users: users ?? this.users,
      createdBy: createdBy ?? this.createdBy,
      createdOn: createdOn ?? this.createdOn,
      modifiedOn: modifiedOn ?? this.modifiedOn,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'amount': amount,
      'category': category,
      'users': users.map((x) => x.toMap()).toList(),
      'createdBy': createdBy.toMap(),
      'createdOn': createdOn.toString(),
      'modifiedOn': modifiedOn.toString(),
    };
  }

  factory TransactionModel.fromNewTransaction(NewTransactionModel data) {
    return TransactionModel(
      id: data.id,
      description: data.description,
      amount: data.amount,
      category: data.category,
      users: data.members,
      createdBy: data.createdBy,
      createdOn: data.createdOn,
      modifiedOn: data.createdOn,
    );
  }

  factory TransactionModel.fromPersonalExpense(
    PersonalExpenseTransactionModel data,
  ) {
    return TransactionModel(
      id: data.id,
      description: data.description,
      amount: data.amount,
      category: data.category,
      users: [],
      createdBy: UserAmountModel.empty(),
      createdOn: data.createdOn,
      modifiedOn: data.modifiedOn,
    );
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      description: map['description'] as String,
      amount: map['amount'] as double,
      category: map['category'] as String,
      users: List<UserAmountModel>.from(
        (map['users']).map((x) => UserAmountModel.fromMap(x)),
      ),
      createdBy: UserAmountModel.fromMap(map['createdBy']),
      createdOn: DateTime.parse(map['createdOn']),
      modifiedOn: DateTime.parse(map['modifiedOn']),
    );
  }

  String toJson() => json.encode(toMap());

  factory TransactionModel.fromJson(String source) =>
      TransactionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TransactionModel(id: $id, description: $description, amount: $amount, category: $category)';
  }

  @override
  bool operator ==(covariant TransactionModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.amount == amount &&
        other.category == category &&
        listEquals(other.users, users) &&
        other.createdBy == createdBy &&
        other.createdOn == createdOn &&
        other.modifiedOn == modifiedOn;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        description.hashCode ^
        amount.hashCode ^
        category.hashCode ^
        users.hashCode ^
        createdBy.hashCode ^
        createdOn.hashCode ^
        modifiedOn.hashCode;
  }
}
