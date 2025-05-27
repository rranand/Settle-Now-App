// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:settlenow_v2/util/handler/crypto.dart';

class LoginActivityModel {
  bool hasData = true;
  String id = "";
  String deviceName = "";
  String deviceType = "";
  DateTime lastLoggedIn = DateTime.now();
  DateTime createdOn = DateTime.now();

  LoginActivityModel({
    required this.id,
    required this.deviceName,
    required this.deviceType,
    required this.lastLoggedIn,
    required this.createdOn,
  });

  LoginActivityModel.empty({this.hasData = false});

  LoginActivityModel copyWith({
    String? id,
    String? deviceName,
    String? deviceType,
    DateTime? lastLoggedIn,
    DateTime? createdOn,
  }) {
    return LoginActivityModel(
      id: id ?? this.id,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      lastLoggedIn: lastLoggedIn ?? this.lastLoggedIn,
      createdOn: createdOn ?? this.createdOn,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'lastLoggedIn': lastLoggedIn.toString(),
      'createdOn': createdOn.toString(),
    };
  }

  factory LoginActivityModel.fromMap(Map<String, dynamic> map) {
    return LoginActivityModel(
      id: Crypto.decrypt(map['id']),
      deviceName: Crypto.decrypt(map['deviceName']),
      deviceType: Crypto.decrypt(map['deviceType']),
      lastLoggedIn: DateTime.parse(Crypto.decrypt(map['lastLoggedIn'])),
      createdOn: DateTime.parse(Crypto.decrypt(map['createdOn'])),
    );
  }

  String toJson() => json.encode(toMap());

  factory LoginActivityModel.fromJson(String source) =>
      LoginActivityModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'LoginActivityModel(id: $id, deviceName: $deviceName, deviceType: $deviceType, lastLoggedIn: $lastLoggedIn, createdOn: $createdOn)';
  }

  @override
  bool operator ==(covariant LoginActivityModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.deviceName == deviceName &&
        other.deviceType == deviceType &&
        other.lastLoggedIn == lastLoggedIn &&
        other.createdOn == createdOn;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        deviceName.hashCode ^
        deviceType.hashCode ^
        lastLoggedIn.hashCode ^
        createdOn.hashCode;
  }
}
