// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/model/lenden_user_model.dart';

import 'package:settlenow_v2/util/handler/crypto.dart';

class LendenDashboardModel {
  bool hasData = true;
  String id = "";
  String roomName = "";
  String status = "";
  DateTime createdOn = DateTime.now();
  double amount = 0;
  List<LendenUserModel> users = [];

  LendenDashboardModel({
    required this.id,
    required this.roomName,
    required this.status,
    required this.createdOn,
    required this.amount,
    required this.users,
  });

  LendenDashboardModel.empty({this.hasData = false});

  LendenDashboardModel copyWith({
    String? id,
    String? roomName,
    String? status,
    DateTime? createdOn,
    DateTime? modifiedOn,
    double? amount,
    List<LendenUserModel>? users,
  }) {
    return LendenDashboardModel(
      id: id ?? this.id,
      roomName: roomName ?? this.roomName,
      status: status ?? this.status,
      createdOn: createdOn ?? this.createdOn,
      amount: amount ?? this.amount,
      users: users ?? this.users,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'roomName': roomName,
      'status': status,
      'createdOn': createdOn.toString(),
      'amount': amount.toString(),
      'users': users.map((x) => x.toMap()).toList(),
    };
  }

  factory LendenDashboardModel.fromMap(Map<String, dynamic> map) {
    return LendenDashboardModel(
      id: Crypto.decrypt(map['id']),
      roomName: Crypto.decrypt(map['roomName']),
      status: Crypto.decrypt(map['status']),
      createdOn: DateTime.parse(Crypto.decrypt(map['createdOn'])),
      amount: double.parse(Crypto.decrypt(map['amount'])),
      users: List<LendenUserModel>.from(
        (map['users']).map((x) => LendenUserModel.fromBasicInfoMap(x)),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory LendenDashboardModel.fromJson(String source) =>
      LendenDashboardModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'LendenDashboardModel(id: $id, roomName: $roomName, amount $amount,status $status, createdOn: $createdOn)';
  }

  @override
  bool operator ==(covariant LendenDashboardModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.roomName == roomName &&
        other.status == status &&
        other.createdOn == createdOn &&
        other.amount == amount &&
        listEquals(other.users, users);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        roomName.hashCode ^
        status.hashCode ^
        createdOn.hashCode ^
        amount.hashCode ^
        users.hashCode;
  }
}
