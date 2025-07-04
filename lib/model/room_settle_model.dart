// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/util/handler/crypto.dart';

class RoomSettleModel {
  bool hasData = true;
  String id = "";
  UserModel recevier = UserModel.empty();
  UserModel sender = UserModel.empty();
  double amount = 0;
  DateTime createdOn = DateTime.now();
  DateTime modifiedOn = DateTime.now();

  RoomSettleModel({
    required this.id,
    required this.recevier,
    required this.sender,
    required this.amount,
    required this.createdOn,
    required this.modifiedOn,
  });

  RoomSettleModel.empty({this.hasData = false});

  RoomSettleModel copyWith({
    String? id,
    UserModel? recevier,
    UserModel? sender,
    double? amount,
    DateTime? createdOn,
    DateTime? modifiedOn,
  }) {
    return RoomSettleModel(
      id: id ?? this.id,
      recevier: recevier ?? this.recevier,
      sender: sender ?? this.sender,
      amount: amount ?? this.amount,
      createdOn: createdOn ?? this.createdOn,
      modifiedOn: modifiedOn ?? this.modifiedOn,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'recevier': recevier.toMap(),
      'sender': sender.toMap(),
      'amount': amount,
      'createdOn': createdOn.toString(),
      'modifiedOn': modifiedOn.toString(),
    };
  }

  factory RoomSettleModel.fromMap(Map<String, dynamic> map) {
    return RoomSettleModel(
      id: Crypto.decrypt(map['id']),
      recevier: UserModel.fromBasicInfoMap(
        map['recevier'] as Map<String, dynamic>,
      ),
      sender: UserModel.fromBasicInfoMap(map['sender'] as Map<String, dynamic>),
      amount: double.parse(Crypto.decrypt(map['amount'])),
      createdOn: DateTime.parse(Crypto.decrypt(map['createdOn'])).toLocal(),
      modifiedOn: DateTime.parse(Crypto.decrypt(map['modifiedOn'])).toLocal(),
    );
  }

  String toSettleTransactionJSON() {
    Map<String, String> data = {
      'id': Crypto.encrypt(""),
      'amount': Crypto.encrypt(amount.toString()),
      'sender': Crypto.encrypt(sender.id),
      'recevier': Crypto.encrypt(recevier.id),
    };

    return json.encode(data);
  }

  String toJson() => json.encode(toMap());

  factory RoomSettleModel.fromJson(String source) =>
      RoomSettleModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RoomSettleModel(id: $id, recevier: $recevier, sender: $sender, amount: $amount, createdOn: $createdOn, modifiedOn: $modifiedOn)';
  }

  @override
  bool operator ==(covariant RoomSettleModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.recevier == recevier &&
        other.sender == sender &&
        other.amount == amount &&
        other.createdOn == createdOn &&
        other.modifiedOn == modifiedOn;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        recevier.hashCode ^
        sender.hashCode ^
        amount.hashCode ^
        createdOn.hashCode ^
        modifiedOn.hashCode;
  }
}
