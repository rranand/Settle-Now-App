// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/model/room_user_model.dart';

import 'package:settlenow_v2/util/handler/crypto.dart';

class RoomInfoModel {
  bool hasData = true;
  String id = "";
  String roomName = "";
  String roomKey = "";
  String roomLink = "";
  String status = "";
  DateTime createdOn = DateTime.now();
  List<RoomUserModel> users = [];
  bool active = true;

  RoomInfoModel({
    required this.id,
    required this.roomName,
    required this.roomKey,
    required this.roomLink,
    required this.status,
    required this.createdOn,
    required this.users,
    required this.active,
  });

  RoomInfoModel.empty({this.hasData = false});

  RoomInfoModel copyWith({
    String? id,
    String? roomName,
    String? status,
    String? roomKey,
    String? roomLink,
    DateTime? createdOn,
    List<RoomUserModel>? users,
    bool? active,
  }) {
    return RoomInfoModel(
      id: id ?? this.id,
      roomName: roomName ?? this.roomName,
      status: status ?? this.status,
      createdOn: createdOn ?? this.createdOn,
      users: users ?? this.users,
      roomKey: roomKey ?? this.roomKey,
      roomLink: roomLink ?? this.roomLink,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'roomName': roomName,
      'status': status,
      'roomKey': roomKey,
      'roomLink': roomLink,
      'createdOn': createdOn.toString(),
      'users': users.map((x) => x.toMap()).toList(),
      'active': active,
    };
  }

  factory RoomInfoModel.fromMap(Map<String, dynamic> map) {
    return RoomInfoModel(
      id: Crypto.decrypt(map['id']),
      roomName: Crypto.decrypt(map['roomName']),
      status: Crypto.decrypt(map['status']),
      roomKey: Crypto.decrypt(map['roomKey']),
      roomLink: Crypto.decrypt(map['roomLink']),
      createdOn: DateTime.parse(Crypto.decrypt(map['createdOn'])),
      users: List<RoomUserModel>.from(
        (map['users']).map((x) => RoomUserModel.fromBasicInfoMap(x)),
      ),
      active: Crypto.decrypt(map['active']) == 'true',
    );
  }

  String toJson() => json.encode(toMap());

  factory RoomInfoModel.fromJson(String source) =>
      RoomInfoModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RoomInfoModel(id: $id, active: $active roomName: $roomName, roomKey: $roomKey, status $status, createdOn: $createdOn)';
  }

  @override
  bool operator ==(covariant RoomInfoModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.active == active &&
        other.roomName == roomName &&
        other.roomKey == roomKey &&
        other.roomLink == roomLink &&
        other.status == status &&
        other.createdOn == createdOn &&
        listEquals(other.users, users);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        active.hashCode ^
        roomName.hashCode ^
        roomKey.hashCode ^
        roomLink.hashCode ^
        status.hashCode ^
        createdOn.hashCode ^
        users.hashCode;
  }
}
