// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:settlenow_v2/model/user_model.dart';

class RoomInfoModel {
  bool hasData = true;
  String id = "";
  String roomName = "";
  String status = "";
  DateTime createdOn = DateTime.now();
  DateTime modifiedOn = DateTime.now();
  List<UserModel> users = [];

  RoomInfoModel({
    required this.id,
    required this.roomName,
    required this.status,
    required this.createdOn,
    required this.modifiedOn,
    required this.users,
  });

  RoomInfoModel.empty({this.hasData = false});

  RoomInfoModel copyWith({
    String? id,
    String? roomName,
    String? status,
    DateTime? createdOn,
    DateTime? modifiedOn,
    List<UserModel>? users,
  }) {
    return RoomInfoModel(
      id: id ?? this.id,
      roomName: roomName ?? this.roomName,
      status: status ?? this.status,
      createdOn: createdOn ?? this.createdOn,
      modifiedOn: modifiedOn ?? this.modifiedOn,
      users: users ?? this.users,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'roomName': roomName,
      'status': status,
      'createdOn': createdOn.toString(),
      'modifiedOn': modifiedOn.toString(),
      'users': users.map((x) => x.toMap()).toList(),
    };
  }

  factory RoomInfoModel.fromMap(Map<String, dynamic> map) {
    return RoomInfoModel(
      id: map['id'] as String,
      roomName: map['roomName'] as String,
      status: map['status'] as String,
      createdOn: DateTime.parse(map['createdOn']),
      modifiedOn: DateTime.parse(map['modifiedOn']),
      users: List<UserModel>.from(
        (map['users']).map((x) => UserModel.fromMap(x)),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory RoomInfoModel.fromJson(String source) =>
      RoomInfoModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RoomInfoModel(id: $id, roomName: $roomName, status $status, createdOn: $createdOn)';
  }

  @override
  bool operator ==(covariant RoomInfoModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.roomName == roomName &&
        other.status == status &&
        other.createdOn == createdOn &&
        other.modifiedOn == modifiedOn &&
        listEquals(other.users, users);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        roomName.hashCode ^
        status.hashCode ^
        createdOn.hashCode ^
        modifiedOn.hashCode ^
        users.hashCode;
  }
}
