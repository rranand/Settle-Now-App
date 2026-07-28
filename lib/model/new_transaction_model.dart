// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow/model/model_core.dart';

class NewTransactionModel {
  bool hasData = true;
  String id = "";
  String description = "";
  double amount = 0;
  String category = "";
  String splitType = "";
  UserAmountModel createdBy = UserAmountModel.empty();
  List<UserAmountModel> members = [];
  DateTime createdOn = DateTime.now();

  NewTransactionModel({
    required this.amount,
    required this.description,
    required this.createdOn,
    required this.members,
    required this.createdBy,
    required this.category,
    required this.splitType,
  });

  NewTransactionModel.empty({this.hasData = false});

  NewTransactionModel copyWith({
    double? amount,
    String? description,
    DateTime? createdOn,
    List<UserAmountModel>? members,
    UserAmountModel? createdBy,
    String? category,
    String? splitType,
  }) {
    return NewTransactionModel(
      amount: amount ?? this.amount,
      description: description ?? this.description,
      createdOn: createdOn ?? this.createdOn,
      members: members ?? this.members,
      createdBy: createdBy ?? this.createdBy,
      category: category ?? this.category,
      splitType: splitType ?? this.splitType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'amount': amount,
      'description': description,
      'created_on': createdOn.toString(),
      'members': members.map((x) => x.toMap()).toList(),
      'createdBy': createdBy.toMap(),
      'category': category,
      'splitType': splitType,
    };
  }

  factory NewTransactionModel.fromBulkTransaction(
    BulkTransactionModel data,
    String id,
    String createdByUID,
    List<RoomUserModel> users,
  ) {
    List<UserAmountModel> userWithAmount = [];
    UserAmountModel createdBy = UserAmountModel.empty();
    int amountInPaisa =
        (Decimal.parse(data.amount.toString()) * Decimal.fromInt(100))
            .toBigInt()
            .toInt();
    int remaining = amountInPaisa % users.length;
    int eachAmount = (amountInPaisa / users.length).toInt();

    for (int i = 0; i < users.length; i++) {
      if (users[i].user.id == createdByUID) {
        createdBy = UserAmountModel.copyFromUser(
          users[i].user,
          ((eachAmount + (remaining > 0 ? 1 : 0)) / 100),
        );
      } else {
        userWithAmount.add(
          UserAmountModel.copyFromUser(
            users[i].user,
            ((eachAmount + (remaining > 0 ? 1 : 0)) / 100),
          ),
        );
      }
      remaining--;
    }
    NewTransactionModel newTransData = NewTransactionModel(
      amount: data.amount,
      description: data.description,
      createdOn: DateTime.now(),
      members: userWithAmount,
      createdBy: createdBy,
      category: data.category,
      splitType: "equal",
    );

    newTransData.id = id;
    return newTransData;
  }

  factory NewTransactionModel.fromMap(Map<String, dynamic> map) {
    return NewTransactionModel(
      amount: map['amount'] as double,
      description: map['description'] as String,
      createdOn: DateTime.parse(map['created_on'] as String),
      members: List<UserAmountModel>.from(
        (map['members'] as List<int>).map<UserAmountModel>(
          (x) => UserAmountModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      createdBy: UserAmountModel.fromMap(
        map['createdBy'] as Map<String, dynamic>,
      ),
      category: map['category'] as String,
      splitType: map['splitType'] ?? "equal",
    );
  }

  String toJson() => json.encode(toMap());

  factory NewTransactionModel.fromJson(String source) =>
      NewTransactionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NewTransactionModel(amount: $amount, description: $description, createdOn: $createdOn, members: $members, createdBy: $createdBy, category: $category)';
  }

  @override
  bool operator ==(covariant NewTransactionModel other) {
    if (identical(this, other)) return true;

    return other.amount == amount &&
        other.description == description &&
        other.createdOn == createdOn &&
        listEquals(other.members, members) &&
        other.createdBy.id == createdBy.id &&
        other.category == category &&
        other.splitType == splitType;
  }

  int generateMembersHash(List<UserAmountModel> members) {
    int result = 17;
    for (var m in members) {
      result = 37 * result + m.hashCode;
    }
    return result;
  }

  @override
  int get hashCode {
    return amount.hashCode ^
        description.hashCode ^
        createdOn.hashCode ^
        generateMembersHash(members) ^
        createdBy.id.hashCode ^
        category.hashCode ^
        splitType.hashCode;
  }
}
