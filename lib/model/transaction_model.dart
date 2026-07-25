// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:settlenow/model/model_core.dart';

class TransactionModel implements CommonTransactionField {
  bool hasData = true;
  String id = "";
  String category = "";
  String splitType = "";
  UserAmountModel createdBy = UserAmountModel.empty();
  List<UserAmountModel> users = [];
  DateTime modifiedOn = DateTime.now();
  bool isAddedToPersonalExpense = false;
  bool active = true;
  bool isClosedAny = false;
  @override
  String description = "";
  @override
  double amount = 0;
  @override
  DateTime createdOn = DateTime.now();

  TransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.users,
    required this.splitType,
    required this.createdBy,
    required this.createdOn,
    required this.modifiedOn,
    required this.isAddedToPersonalExpense,
    this.active = true,
    this.isClosedAny = false,
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
    bool? active,
    bool? isClosedAny,
    String? splitType,
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
      active: active ?? this.active,
      isClosedAny: isClosedAny ?? this.isClosedAny,
      splitType: splitType ?? this.splitType,
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
      'splitType': splitType.toString(),
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
      splitType: data.splitType,
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
      splitType: "",
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
      splitType: "",
      isAddedToPersonalExpense: false,
    );
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      description: map['description'],
      amount: double.parse(map['amount'].toString()),
      category: map['category'],
      users: List<UserAmountModel>.from(
        (map['users']).map((x) => UserAmountModel.fromBasicInfoMap(x)),
      ),
      createdBy: UserAmountModel.fromBasicInfoMap(map['createdBy']),
      createdOn: DateTime.parse(map['created_on']).toLocal(),
      modifiedOn: DateTime.parse(map['modified_on']).toLocal(),
      isAddedToPersonalExpense: map['isAddedToPersonalExpense'],
      isClosedAny: map.containsKey('isClosedAny') ? map['isClosedAny'] : false,
      active: map.containsKey('active') ? map['active'] : true,
      splitType: map.containsKey('splitType') ? map['splitType'] : "",
    );
  }

  String toJson() => json.encode(toMap());

  String toQuickSplitJson() {
    List<String> userData = users.map((e) => e.toQuickSplitJson()).toList();
    Map<String, String> data = {
      "id": id,
      "description": description,
      "amount": amount.toString(),
      "category": category,
      "createdOn": createdOn.toIso8601String(),
      "users": json.encode(userData),
      "createdBy": createdBy.toQuickSplitJson(),
      "splitType": splitType,
    };
    return json.encode(data);
  }

  String toQuickSplitUpdateJson({Map<String, String> extraData = const {}}) {
    List<String> userData = users.map((e) => e.toQuickSplitJson()).toList();
    Map<String, String> data = {
      "id": id,
      "description": description,
      "amount": amount.toString(),
      "category": category,
      "users": json.encode(userData),
      "createdBy": createdBy.toQuickSplitJson(),
      "splitType": splitType,
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
        other.modifiedOn == modifiedOn &&
        other.splitType == splitType;
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
        modifiedOn.hashCode ^
        splitType.hashCode;
  }
}

extension ToQuickSplitJsonList on List<TransactionModel> {
  String toQuickSplitJson() {
    return json.encode(map((e) => e.toQuickSplitJson()).toList());
  }
}
