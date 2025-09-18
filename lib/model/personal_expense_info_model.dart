// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:settlenow/constant/calender_constant.dart';
import 'package:settlenow/util/handler/crypto.dart';

class PersonalExpenseInfoModel {
  bool hasData = true;
  String id = "";
  double amount = 0;
  String monthName = "";
  String year = "";
  List<double> transaction = [];

  PersonalExpenseInfoModel({
    required this.id,
    required this.amount,
    required this.monthName,
    required this.year,
    required this.transaction,
  });

  PersonalExpenseInfoModel.empty({this.hasData = false});

  PersonalExpenseInfoModel copyWith({
    String? id,
    double? amount,
    String? monthName,
    String? year,
    List<double>? transaction,
  }) {
    return PersonalExpenseInfoModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      monthName: monthName ?? this.monthName,
      year: year ?? this.year,
      transaction: transaction ?? this.transaction,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'amount': amount,
      'monthName': monthName,
      'year': year,
      'transaction': transaction,
    };
  }

  factory PersonalExpenseInfoModel.fromMap(Map<String, dynamic> map) {
    List<double> transaction = [];
    for (int i = 0; i < map["transaction"].length; i++) {
      transaction.add(double.parse(Crypto.decrypt(map["transaction"][i])));
    }
    return PersonalExpenseInfoModel(
      id: Crypto.decrypt(map['id']),
      amount: double.parse(Crypto.decrypt(map['amount'])),
      monthName:
          CalenderConstant.monthName[int.parse(
            Crypto.decrypt(map['monthName']),
          )],
      year: Crypto.decrypt(map['year']),
      transaction: transaction,
    );
  }

  String toJson() => json.encode(toMap());

  factory PersonalExpenseInfoModel.fromJson(String source) =>
      PersonalExpenseInfoModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  String toString() {
    return 'PersonalExpenseInfoModel(monthName: $monthName, year: $year, amount: $amount)';
  }

  @override
  bool operator ==(covariant PersonalExpenseInfoModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.amount == amount &&
        other.monthName == monthName &&
        other.year == year &&
        listEquals(other.transaction, transaction);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        monthName.hashCode ^
        year.hashCode ^
        transaction.hashCode;
  }
}
