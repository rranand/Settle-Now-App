// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:settlenow/core.dart';
import 'package:settlenow/util/handler/crypto.dart';

class RoomSettleModel {
  bool hasData = true;
  String id = "";
  UserModel receiver = UserModel.empty();
  UserModel sender = UserModel.empty();
  double amount = 0;
  DateTime createdOn = DateTime.now();
  DateTime modifiedOn = DateTime.now();

  RoomSettleModel({
    required this.id,
    required this.receiver,
    required this.sender,
    required this.amount,
    required this.createdOn,
    required this.modifiedOn,
  });

  RoomSettleModel.empty({this.hasData = false});

  RoomSettleModel copyWith({
    String? id,
    UserModel? receiver,
    UserModel? sender,
    double? amount,
    DateTime? createdOn,
    DateTime? modifiedOn,
  }) {
    return RoomSettleModel(
      id: id ?? this.id,
      receiver: receiver ?? this.receiver,
      sender: sender ?? this.sender,
      amount: amount ?? this.amount,
      createdOn: createdOn ?? this.createdOn,
      modifiedOn: modifiedOn ?? this.modifiedOn,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'receiver': receiver.toMap(),
      'sender': sender.toMap(),
      'amount': amount,
      'createdOn': createdOn.toString(),
      'modifiedOn': modifiedOn.toString(),
    };
  }

  factory RoomSettleModel.fromMap(Map<String, dynamic> map) {
    return RoomSettleModel(
      id: Crypto.decrypt(map['id']),
      receiver: UserModel.fromBasicInfoMap(
        map['receiver'] as Map<String, dynamic>,
      ),
      sender: UserModel.fromBasicInfoMap(map['sender'] as Map<String, dynamic>),
      amount: double.parse(Crypto.decrypt(map['amount'])),
      createdOn: DateTime.parse(Crypto.decrypt(map['createdOn'])).toLocal(),
      modifiedOn: DateTime.parse(Crypto.decrypt(map['modifiedOn'])).toLocal(),
    );
  }

  String toSettleTransactionJSON() {
    Map<String, String> data = {
      'id': Crypto.encrypt(id),
      'amount': Crypto.encrypt(amount.toString()),
      'sender': Crypto.encrypt(sender.id),
      'receiver': Crypto.encrypt(receiver.id),
    };

    return json.encode(data);
  }

  String toJson() => json.encode(toMap());

  factory RoomSettleModel.fromJson(String source) =>
      RoomSettleModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RoomSettleModel(id: $id, receiver: $receiver, sender: $sender, amount: $amount, createdOn: $createdOn, modifiedOn: $modifiedOn)';
  }

  @override
  bool operator ==(covariant RoomSettleModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.receiver == receiver &&
        other.sender == sender &&
        other.amount == amount &&
        other.createdOn == createdOn &&
        other.modifiedOn == modifiedOn;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        receiver.hashCode ^
        sender.hashCode ^
        amount.hashCode ^
        createdOn.hashCode ^
        modifiedOn.hashCode;
  }
}
