// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class LendenDashboardModel {
  bool hasData = true;
  String id = "";
  String roomName = "";
  RoomStatus status = RoomStatus.none;
  String createdBy = "";
  DateTime createdOn = DateTime.now();
  DateTime modifiedOn = DateTime.now();
  List<LendenUserModel> users = [];

  LendenDashboardModel({
    required this.id,
    required this.roomName,
    required this.status,
    required this.createdBy,
    required this.createdOn,
    required this.modifiedOn,
    required this.users,
  });

  LendenDashboardModel.empty({this.hasData = false});

  LendenDashboardModel copyWith({
    String? id,
    String? roomName,
    RoomStatus? status,
    String? createdBy,
    DateTime? createdOn,
    DateTime? modifiedOn,
    List<LendenUserModel>? users,
  }) {
    return LendenDashboardModel(
      id: id ?? this.id,
      roomName: roomName ?? this.roomName,
      status: status ?? this.status,
      createdOn: createdOn ?? this.createdOn,
      createdBy: createdBy ?? this.createdBy,
      modifiedOn: modifiedOn ?? this.modifiedOn,
      users: users ?? this.users,
    );
  }

  Pair<double, double> getAmount() {
    final loggedInUser = UserResolver.instance.getLoggedInUser();
    if (users.isEmpty) {
      return Pair(0, 0);
    }

    final me = users.firstWhere(
      (each) => each.id == loggedInUser.id,
      orElse: () => LendenUserModel.empty(),
    );

    if (!me.hasData) return Pair(0, 0);

    if (users.length == 1) return Pair(me.gave, me.owe);

    final other = users.firstWhere((u) => u.id != loggedInUser.id);

    final gave = me.gave + other.owe;
    final owe = me.owe + other.gave;

    return Pair(gave, owe);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'room_name': roomName,
      'status': status,
      'created_by': createdBy,
      'created_on': createdOn.toString(),
      'modified_on': modifiedOn.toString(),
      'users': users.map((x) => x.toMap()).toList(),
    };
  }

  factory LendenDashboardModel.fromMap(Map<String, dynamic> map) {
    return LendenDashboardModel(
      id: map['id'],
      roomName: map['room_name'],
      status: RoomStatusExtension.fromString(map['status']),
      createdBy: map['created_by'],
      createdOn: DateTime.parse(map['created_on']).toLocal(),
      modifiedOn: DateTime.parse(map['modified_on']).toLocal(),
      users: List<LendenUserModel>.from(
        (map['users']).map((x) => LendenUserModel.fromUserResolver(x)),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory LendenDashboardModel.fromJson(String source) =>
      LendenDashboardModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'LendenDashboardModel(id: $id, roomName: $roomName, status $status, createdOn: $createdOn)';
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
        Object.hashAll(users);
  }
}
