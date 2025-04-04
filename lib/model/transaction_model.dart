import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/model/user_model.dart';

class Transaction {
  bool hasData = true;
  String id;
  String purpose;
  double amount;
  DateTime createdOn;
  DateTime modifiedOn;
  UserModel createdBy;
  String category;
  List<UserModel> splittedBetween = [];

  Transaction({
    required this.id,
    required this.purpose,
    required this.amount,
    required this.createdOn,
    required this.modifiedOn,
    required this.createdBy,
    required this.category,
    required this.splittedBetween,
  });

  Transaction copyWith({
    String? id,
    String? purpose,
    double? amount,
    DateTime? createdOn,
    DateTime? modifiedOn,
    UserModel? createdBy,
    String? category,
    List<UserModel>? splittedBetween,
  }) {
    return Transaction(
      id: id ?? this.id,
      purpose: purpose ?? this.purpose,
      amount: amount ?? this.amount,
      createdOn: createdOn ?? this.createdOn,
      modifiedOn: modifiedOn ?? this.modifiedOn,
      createdBy: createdBy ?? this.createdBy,
      category: category ?? this.category,
      splittedBetween: splittedBetween ?? this.splittedBetween,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'purpose': purpose,
      'amount': amount,
      'createdOn': createdOn.millisecondsSinceEpoch,
      'modifiedOn': modifiedOn.millisecondsSinceEpoch,
      'createdBy': createdBy.toMap(),
      'category': category,
      'splittedBetween': splittedBetween.map((x) => x.toMap()).toList(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      purpose: map['purpose'] as String,
      amount: map['amount'] as double,
      createdOn: DateTime.fromMillisecondsSinceEpoch(map['createdOn'] as int),
      modifiedOn: DateTime.fromMillisecondsSinceEpoch(map['modifiedOn'] as int),
      createdBy: UserModel.fromMap(map['createdBy'] as Map<String, dynamic>),
      category: map['category'] as String,
      splittedBetween: List<UserModel>.from(
        (map['splittedBetween'] as List<int>).map<UserModel>(
          (x) => UserModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Transaction.fromJson(String source) =>
      Transaction.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Transaction(id: $id, purpose: $purpose, amount: $amount, createdOn: $createdOn, modifiedOn: $modifiedOn, createdBy: $createdBy, category: $category, splittedBetween: $splittedBetween)';
  }

  @override
  bool operator ==(covariant Transaction other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.purpose == purpose &&
        other.amount == amount &&
        other.createdOn == createdOn &&
        other.modifiedOn == modifiedOn &&
        other.createdBy == createdBy &&
        other.category == category &&
        listEquals(other.splittedBetween, splittedBetween);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        purpose.hashCode ^
        amount.hashCode ^
        createdOn.hashCode ^
        modifiedOn.hashCode ^
        createdBy.hashCode ^
        category.hashCode ^
        splittedBetween.hashCode;
  }
}
