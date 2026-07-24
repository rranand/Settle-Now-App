import 'dart:convert';

import 'package:settlenow/model/common_transaction_field.dart';
import 'package:settlenow/model/lenden_user_model.dart';
import 'package:settlenow/model/new_transaction_model.dart';

class LendenTransactionModel implements CommonTransactionField {
  bool hasData = true;
  String id = "";
  LendenUserModel createdBy = LendenUserModel.empty();
  DateTime modifiedOn = DateTime.now();
  @override
  double amount = 0;
  @override
  String description = "";
  @override
  DateTime createdOn = DateTime.now();

  LendenTransactionModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.createdOn,
    required this.createdBy,
    required this.modifiedOn,
  });

  LendenTransactionModel.empty({this.hasData = false});

  LendenTransactionModel copyWith({
    String? id,
    double? amount,
    String? description,
    DateTime? createdOn,
    LendenUserModel? createdBy,
    DateTime? modifiedOn,
  }) {
    return LendenTransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      createdOn: createdOn ?? this.createdOn,
      createdBy: createdBy ?? this.createdBy,
      modifiedOn: modifiedOn ?? this.modifiedOn,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'amount': amount,
      'description': description,
      'createdOn': createdOn.toString(),
      'createdBy': createdBy,
      'modifiedOn': modifiedOn.toString(),
    };
  }

  factory LendenTransactionModel.fromMap(
    Map<String, dynamic> map,
    List<LendenUserModel> users,
  ) {
    return LendenTransactionModel(
      id: map['id'],
      amount: double.parse(map['amount'].toString()),
      description: map['description'],
      createdOn: DateTime.parse(map['created_on']).toLocal(),
      modifiedOn: DateTime.parse(map['modified_on']).toLocal(),
      createdBy: users.firstWhere((user) => user.id == map['created_by']),
    );
  }

  factory LendenTransactionModel.fromNewTransaction(NewTransactionModel data) {
    return LendenTransactionModel(
      id: data.id,
      amount: data.amount,
      description: data.description,
      createdOn: data.createdOn,
      createdBy: LendenUserModel.fromUserModel(data.createdBy),
      modifiedOn: data.createdOn,
    );
  }

  String toCreateExpenseJson() {
    Map<String, String> data = {
      "amount": amount.toString(),
      "description": description,
      "createdOn": createdOn.toIso8601String(),
    };

    return json.encode(data);
  }

  String toUpdateExpenseJson() {
    Map<String, String> data = {
      "id": id,
      "amount": amount.toString(),
      "description": description,
    };

    return json.encode(data);
  }

  String toJson() => json.encode(toMap());

  factory LendenTransactionModel.fromJson(String source) =>
      LendenTransactionModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
        [],
      );

  @override
  String toString() {
    return 'LendenTransactionModel(id: $id, amount: $amount, createdBy: $createdBy, description: $description)';
  }

  @override
  bool operator ==(covariant LendenTransactionModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.amount == amount &&
        other.description == description &&
        other.createdOn == createdOn &&
        other.createdBy == createdBy &&
        other.modifiedOn == modifiedOn;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        description.hashCode ^
        createdOn.hashCode ^
        createdBy.hashCode ^
        modifiedOn.hashCode;
  }
}
