import 'dart:convert';

import 'package:settlenow_v2/model/lenden_user_model.dart';
import 'package:settlenow_v2/model/new_transaction_model.dart';
import 'package:settlenow_v2/util/handler/crypto.dart';

class LendenTransactionModel {
  bool hasData = true;
  String id = "";
  double amount = 0;
  String description = "";
  DateTime createdOn = DateTime.now();
  LendenUserModel createdBy = LendenUserModel.empty();
  DateTime modifiedOn = DateTime.now();

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

  @override
  factory LendenTransactionModel.fromMap(
    Map<String, dynamic> map,
    List<LendenUserModel> users,
  ) {
    return LendenTransactionModel(
      id: Crypto.decrypt(map['id']),
      amount: double.parse(Crypto.decrypt(map['amount'])),
      description: Crypto.decrypt(map['description']),
      createdOn: DateTime.parse(Crypto.decrypt(map['createdOn'])),
      createdBy: users.firstWhere(
        (user) => user.id == Crypto.decrypt(map['createdBy']),
      ),
      modifiedOn: DateTime.parse(Crypto.decrypt(map['modifiedOn'])),
    );
  }

  @override
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
