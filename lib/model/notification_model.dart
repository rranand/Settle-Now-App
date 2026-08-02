import 'dart:convert';
import 'package:settlenow/util/util_core.dart';

import 'model_core.dart';

class NotificationModel {
  bool hasData = true;
  String id = "";
  String roomName = "";
  RoomType type = RoomType.none;
  String roomID = "";
  BaseUserModel invitedBy = BaseUserModel.empty();
  BaseUserModel invitedUser = BaseUserModel.empty();
  DateTime createdOn = DateTime.now();

  NotificationModel.empty({this.hasData = false});

  NotificationModel({
    required this.id,
    required this.roomName,
    required this.type,
    required this.roomID,
    required this.invitedBy,
    required this.invitedUser,
    required this.createdOn,
  });

  @override
  String toString() =>
      'NotificationModel(id: $id, roomName: $roomName, roomID: $roomID, type: $type, invitedUser: $invitedUser, invitedBy: $invitedBy)';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'room_name': roomName,
      'type': type,
      'room_id': roomID,
      'created_on': createdOn,
      'invited_by': invitedBy.toMap(),
      'invited_user': invitedUser.toMap(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      roomName: map['room_name'],
      type: RoomTypeExtension.fromString(map['type']),
      roomID: map['room_id'],
      invitedBy: UserResolver.instance.resolve(map['invited_by']),
      invitedUser: UserResolver.instance.resolve(map['invited_user']),
      createdOn: DateTime.parse(map['created_on']).toLocal(),
    );
  }

  factory NotificationModel.fromLendenMap(
    Map<String, dynamic> map,
    String roomId,
    String roomName,
    String invitedUserId,
  ) {
    final invitedBy = UserResolver.instance.getLoggedInUser();
    final invitedUser = UserResolver.instance.resolve(invitedUserId);

    return NotificationModel(
      id: map['id'],
      roomName: roomName,
      type: RoomType.lenden,
      roomID: roomId,
      invitedBy: invitedBy,
      invitedUser: invitedUser,
      createdOn: DateTime.now(),
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
        other.invitedBy == invitedBy &&
        other.invitedUser == invitedUser;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      roomName.hashCode ^
      type.hashCode ^
      roomID.hashCode ^
      invitedBy.hashCode ^
      invitedUser.hashCode;
}
