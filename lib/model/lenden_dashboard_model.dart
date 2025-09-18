// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:settlenow/model/lenden_user_model.dart';
import 'package:settlenow/model/user_model.dart';

import 'package:settlenow/util/handler/crypto.dart';

class LendenDashboardModel {
  bool hasData = true;
  String id = "";
  String roomName = "";
  String status = "";
  UserModel createdBy = UserModel.empty();
  DateTime createdOn = DateTime.now();
  DateTime modifiedOn = DateTime.now();
  double amount = 0;
  List<LendenUserModel> users = [];

  LendenDashboardModel({
    required this.id,
    required this.roomName,
    required this.status,
    required this.createdBy,
    required this.createdOn,
    required this.modifiedOn,
    required this.amount,
    required this.users,
  });

  LendenDashboardModel.empty({this.hasData = false});

  LendenDashboardModel copyWith({
    String? id,
    String? roomName,
    String? status,
    UserModel? createdBy,
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
      createdBy: createdBy ?? this.createdBy,
      modifiedOn: modifiedOn ?? this.modifiedOn,
      amount: amount ?? this.amount,
      users: users ?? this.users,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'roomName': roomName,
      'status': status,
      'createdBy': createdBy.toMap(),
      'createdOn': createdOn.toString(),
      'modifiedOn': modifiedOn.toString(),
      'amount': amount.toString(),
      'users': users.map((x) => x.toMap()).toList(),
    };
  }

  factory LendenDashboardModel.fromMap(Map<String, dynamic> map) {
    return LendenDashboardModel(
      id: Crypto.decrypt(map['id']),
      roomName: Crypto.decrypt(map['roomName']),
      status: Crypto.decrypt(map['status']),
      createdBy: UserModel.fromBasicInfoMap(map['createdBy']),
      createdOn: DateTime.parse(Crypto.decrypt(map['createdOn'])).toLocal(),
      modifiedOn: DateTime.parse(Crypto.decrypt(map['modifiedOn'])).toLocal(),
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
        other.createdBy == createdBy &&
        other.createdOn == createdOn &&
        other.modifiedOn == modifiedOn &&
        other.amount == amount &&
        listEquals(other.users, users);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        roomName.hashCode ^
        status.hashCode ^
        createdBy.hashCode ^
        createdOn.hashCode ^
        modifiedOn.hashCode ^
        amount.hashCode ^
        users.hashCode;
  }
}
