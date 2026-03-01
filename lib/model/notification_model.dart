import 'dart:convert';

import 'package:settlenow/core.dart';

class NotificationModel {
  bool hasData = true;
  String id = "";
  String roomName = "";
  String type = "";
  String roomID = "";
  UserModel by = UserModel.empty();
  UserModel user = UserModel.empty();
  DateTime createdOn = DateTime.now();

  NotificationModel.empty({this.hasData = false});

  NotificationModel({
    required this.id,
    required this.roomName,
    required this.type,
    required this.roomID,
    required this.by,
    required this.user,
    required this.createdOn,
  });

  @override
  String toString() =>
      'NotificationModel(id: $id, roomName: $roomName, roomID: $roomID, type: $type, user: $user, by: $by)';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'roomName': roomName,
      'type': type,
      'roomID': roomID,
      'createdOn': createdOn,
      'by': by.toMap(),
      'user': user.toMap(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      roomName: map['roomName'],
      type: map['type'],
      roomID: map['roomID'],
      by: UserModel.fromBasicInfoMap(map['by']),
      user: UserModel.fromBasicInfoMap(map['user']),
      createdOn: DateTime.parse(map['createdOn']).toLocal(),
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant NotificationModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.roomName == roomName &&
        other.type == type &&
        other.roomID == roomID &&
        other.by == by &&
        other.user == user;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      roomName.hashCode ^
      type.hashCode ^
      roomID.hashCode ^
      by.hashCode ^
      user.hashCode;
}
