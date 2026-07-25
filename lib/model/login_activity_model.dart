// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:settlenow/util/util_core.dart';

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
      id: map['id'],
      deviceName: map['deviceName'],
      deviceType: capatilizeFirstLetter(map['deviceType'] ?? ""),
      lastLoggedIn: DateTime.parse(map['lastLoggedIn']).toLocal(),
      createdOn: DateTime.parse(map['created_on']).toLocal(),
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
