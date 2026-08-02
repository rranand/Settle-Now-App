import 'package:flutter/foundation.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class RoomInfoModel {
  bool hasData = true;
  String id = "";
  String roomName = "";
  String roomKey = "";
  String roomLink = "";
  RoomStatus status = RoomStatus.none;
  String createdBy = "";
  DateTime createdOn = DateTime.now();
  DateTime modifiedOn = DateTime.now();
  List<RoomUserModel> users = [];
  bool active = true;

  RoomInfoModel({
    required this.id,
    required this.roomName,
    required this.roomKey,
    required this.roomLink,
    required this.status,
    required this.createdBy,
    required this.createdOn,
    required this.modifiedOn,
    required this.users,
    required this.active,
  });

  RoomInfoModel.empty({this.hasData = false});

  RoomInfoModel copyWith({
    String? id,
    String? roomName,
    RoomStatus? status,
    String? roomKey,
    String? roomLink,
    String? createdBy,
    DateTime? createdOn,
    DateTime? modifiedOn,
    List<RoomUserModel>? users,
    bool? active,
  }) {
    return RoomInfoModel(
      id: id ?? this.id,
      roomName: roomName ?? this.roomName,
      status: status ?? this.status,
      createdOn: createdOn ?? this.createdOn,
      createdBy: createdBy ?? this.createdBy,
      modifiedOn: modifiedOn ?? this.modifiedOn,
      users: users ?? this.users,
      roomKey: roomKey ?? this.roomKey,
      roomLink: roomLink ?? this.roomLink,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'room_name': roomName,
      'status': status,
      'room_key': roomKey,
      'room_link': roomLink,
      'created_by': createdBy,
      'created_on': createdOn,
      'modified_on': modifiedOn,
      'users': users.map((x) => x.toMap()).toList(),
      'active': active,
    };
  }

  factory RoomInfoModel.fromMap(Map<String, dynamic> map) {
    final allUsers = List<RoomUserModel>.from(
      (map['users']).map((x) => RoomUserModel.fromMap(x)),
    );

    return RoomInfoModel(
      id: map['id'],
      roomName: map['room_name'],
      status: map['status'],
      roomKey: map['room_key'],
      roomLink: map['room_link'],
      createdBy: map['created_by'],
      createdOn: DateTime.parse(map['created_on']).toLocal(),
      modifiedOn: DateTime.parse(map['modified_on']).toLocal(),
      users: allUsers,
      active: map['active'],
    );
  }

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
        other.createdBy == createdBy &&
        other.createdOn == createdOn &&
        other.modifiedOn == modifiedOn &&
        listEquals(other.users, users);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        active.hashCode ^
        roomName.hashCode ^
        roomKey.hashCode ^
        roomLink.hashCode ^
        createdBy.hashCode ^
        status.hashCode ^
        createdOn.hashCode ^
        modifiedOn.hashCode ^
        users.hashCode;
  }
}
