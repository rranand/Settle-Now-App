// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/model/lenden_room_model.dart';
import 'package:settlenow_v2/model/new_transaction_model.dart';
import 'package:settlenow_v2/model/personal_expense_transaction_model.dart';
import 'package:settlenow_v2/model/user_amount_model.dart';
import 'package:settlenow_v2/util/handler/crypto.dart';

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
  bool isAddedToPersonalExpense = false;

  TransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.users,
    required this.createdBy,
    required this.createdOn,
    required this.modifiedOn,
    required this.isAddedToPersonalExpense,
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
    bool? isAddedToPersonalExpense,
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
      isAddedToPersonalExpense:
          isAddedToPersonalExpense ?? this.isAddedToPersonalExpense,
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
      'isAddedToPersonalExpense': isAddedToPersonalExpense,
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
      isAddedToPersonalExpense: false,
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
      isAddedToPersonalExpense: false,
    );
  }

  factory TransactionModel.fromLendenTransactionModel(
    LendenTransactionModel data,
  ) {
    return TransactionModel(
      id: data.id,
      description: data.description,
      amount: data.amount,
      category: "",
      users: [],
      createdBy: UserAmountModel.copyFromUser(data.createdBy, 0),
      createdOn: data.createdOn,
      modifiedOn: data.modifiedOn,
      isAddedToPersonalExpense: false,
    );
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: Crypto.decrypt(map['id']),
      description: Crypto.decrypt(map['description']),
      amount: double.parse(Crypto.decrypt(map['amount'])),
      category: Crypto.decrypt(map['category']),
      users: List<UserAmountModel>.from(
        (map['users']).map((x) => UserAmountModel.fromBasicInfoMap(x)),
      ),
      createdBy: UserAmountModel.fromBasicInfoMap(map['createdBy']),
      createdOn: DateTime.parse(Crypto.decrypt(map['createdOn'])).toLocal(),
      modifiedOn: DateTime.parse(Crypto.decrypt(map['modifiedOn'])).toLocal(),
      isAddedToPersonalExpense:
          Crypto.decrypt(map['isAddedToPersonalExpense']) == 'true',
    );
  }

  String toJson() => json.encode(toMap());

  String toQuickSplitJson() {
    List<String> userData = users.map((e) => e.toQuickSplitJson()).toList();
    Map<String, String> data = {
      "id": Crypto.encrypt(id),
      "description": Crypto.encrypt(description),
      "amount": Crypto.encrypt(amount.toString()),
      "category": Crypto.encrypt(category),
      "createdOn": Crypto.encrypt(createdOn.toIso8601String()),
      "users": json.encode(userData),
      "createdBy": createdBy.toQuickSplitJson(),
    };
    return json.encode(data);
  }

  String toQuickSplitUpdateJson({Map<String, String> extraData = const {}}) {
    List<String> userData = users.map((e) => e.toQuickSplitJson()).toList();
    Map<String, String> data = {
      "id": Crypto.encrypt(id),
      "description": Crypto.encrypt(description),
      "amount": Crypto.encrypt(amount.toString()),
      "category": Crypto.encrypt(category),
      "users": json.encode(userData),
      "createdBy": createdBy.toQuickSplitJson(),
      ...extraData,
    };
    return json.encode(data);
  }

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
