// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:settlenow_v2/core.dart';

class RoomUserModel {
  bool hasData = true;
  String id = "";
  UserModel user = UserModel.empty();
  double contribution = 0;
  double spent = 0;

  RoomUserModel({
    required this.id,
    required this.user,
    required this.contribution,
    required this.spent,
  });

  RoomUserModel.empty({this.hasData = false});

  RoomUserModel copyWith({
    String? id,
    UserModel? user,
    double? contribution,
    double? spent,
  }) {
    return RoomUserModel(
      id: id ?? this.id,
      user: user ?? this.user,
      contribution: contribution ?? this.contribution,
      spent: spent ?? this.spent,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'user': user.toMap(),
      'contribution': contribution,
      'spent': spent,
    };
  }

  factory RoomUserModel.fromMap(Map<String, dynamic> map) {
    return RoomUserModel(
      id: map['id'] as String,
      user: UserModel.fromBasicInfoMap(map['user']),
      contribution: map['contribution'] as double,
      spent: map['spent'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory RoomUserModel.fromJson(String source) =>
      RoomUserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RoomUserModel(id: $id, user: $user, contribution: $contribution, spent: $spent)';
  }

  @override
  bool operator ==(covariant RoomUserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.user == user &&
        other.contribution == contribution &&
        other.spent == spent;
  }

  @override
  int get hashCode {
    return id.hashCode ^ user.hashCode ^ contribution.hashCode ^ spent.hashCode;
  }
}
