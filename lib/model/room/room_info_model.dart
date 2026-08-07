import 'package:flutter/foundation.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class RoomInfoModel {
  bool hasData = true;
  String id = "";
  String name = "";
  String key = "";
  String link = "";
  RoomStatus status = RoomStatus.none;
  String createdBy = "";
  DateTime createdOn = DateTime.now();
  DateTime modifiedOn = DateTime.now();
  List<RoomUserModel> users = [];
  bool active = true;

  RoomInfoModel({
    required this.id,
    required this.name,
    required this.key,
    required this.link,
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
    String? name,
    RoomStatus? status,
    String? key,
    String? link,
    String? createdBy,
    DateTime? createdOn,
    DateTime? modifiedOn,
    List<RoomUserModel>? users,
    bool? active,
  }) {
    return RoomInfoModel(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      createdOn: createdOn ?? this.createdOn,
      createdBy: createdBy ?? this.createdBy,
      modifiedOn: modifiedOn ?? this.modifiedOn,
      users: users ?? this.users,
      key: key ?? this.key,
      link: link ?? this.link,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'status': status,
      'key': key,
      'link': link,
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
      name: map['name'],
      status: RoomStatusExtension.fromString(map['status']),
      key: map['key'],
      link: map['link'],
      createdBy: map['created_by'],
      createdOn: DateTime.parse(map['created_on']).toLocal(),
      modifiedOn: DateTime.parse(map['modified_on']).toLocal(),
      users: allUsers,
      active: map['active'],
    );
  }

  @override
  String toString() {
    return 'RoomInfoModel(id: $id, active: $active name: $name, key: $key, status $status, createdOn: $createdOn)';
  }

  @override
  bool operator ==(covariant RoomInfoModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.active == active &&
        other.name == name &&
        other.key == key &&
        other.link == link &&
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
        name.hashCode ^
        key.hashCode ^
        link.hashCode ^
        createdBy.hashCode ^
        status.hashCode ^
        createdOn.hashCode ^
        modifiedOn.hashCode ^
        Object.hashAll(users);
  }
}
