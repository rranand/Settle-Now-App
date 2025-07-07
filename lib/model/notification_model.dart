import 'dart:convert';

import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/util/handler/crypto.dart';

class NotificationModel {
  String id = "";
  String name = "";
  String type = "";
  UserModel by = UserModel.empty();
  UserModel user = UserModel.empty();
  DateTime createdOn = DateTime.now();

  NotificationModel({
    required this.id,
    required this.name,
    required this.type,
    required this.by,
    required this.user,
    required this.createdOn,
  });

  @override
  String toString() =>
      'NotificationModel(id: $id, name: $name, type: $type, user: $user, by: $by)';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'type': type,
      'createdOn': createdOn,
      'by': by.toMap(),
      'user': user.toMap(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: Crypto.decrypt(map['id']),
      name: Crypto.decrypt(map['name']),
      type: Crypto.decrypt(map['type']),
      by: UserModel.fromBasicInfoMap(map['by']),
      user: UserModel.fromBasicInfoMap(map['user']),
      createdOn: DateTime.parse(Crypto.decrypt(map['createdOn'])).toLocal(),
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant NotificationModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.type == type &&
        other.by == by &&
        other.user == user &&
        other.createdOn == createdOn;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      by.hashCode ^
      user.hashCode ^
      createdOn.hashCode;
}
