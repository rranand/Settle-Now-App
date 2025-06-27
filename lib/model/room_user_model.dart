// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/util/handler/crypto.dart';

class RoomUserModel {
  bool hasData = true;
  String id = "";
  UserModel user = UserModel.empty();
  double contribution = 0;
  double spent = 0;
  double settle = 0;
  bool active = false;

  RoomUserModel({
    required this.id,
    required this.user,
    required this.contribution,
    required this.spent,
    required this.settle,
    required this.active,
  });

  RoomUserModel.empty({this.hasData = false});

  RoomUserModel copyWith({
    String? id,
    UserModel? user,
    double? contribution,
    double? spent,
    double? settle,
    bool? active,
  }) {
    return RoomUserModel(
      id: id ?? this.id,
      user: user ?? this.user,
      contribution: contribution ?? this.contribution,
      spent: spent ?? this.spent,
      settle: settle ?? this.settle,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'user': user.toMap(),
      'contribution': contribution,
      'spent': spent,
      'settle': settle,
      'active': active,
    };
  }

  @override
  RoomUserModel.fromBasicInfo({
    required this.id,
    required this.user,
    required this.active,
  });

  @override
  factory RoomUserModel.fromBasicInfoMap(Map<String, dynamic> map) {
    return RoomUserModel.fromBasicInfo(
      id: Crypto.decrypt(map['id']),
      user: UserModel.fromBasicInfoMap(map['user']),
      active: Crypto.decrypt(map['active']) == 'true',
    );
  }

  @override
  factory RoomUserModel.fromMap(Map<String, dynamic> map) {
    return RoomUserModel(
      id: map['id'] as String,
      user: UserModel.fromBasicInfoMap(map['user']),
      contribution: map['contribution'] as double,
      spent: map['spent'] as double,
      settle: map['settle'] as double,
      active: map['active'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory RoomUserModel.fromJson(String source) =>
      RoomUserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RoomUserModel(user: $user, active: $active contribution: $contribution, spent: $spent, settle: $settle)';
  }

  @override
  bool operator ==(covariant RoomUserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.user == user &&
        other.active == active &&
        other.contribution == contribution &&
        other.spent == spent &&
        other.settle == settle;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        user.hashCode ^
        active.hashCode ^
        contribution.hashCode ^
        spent.hashCode ^
        settle.hashCode;
  }
}
