import 'package:flutter/foundation.dart';
import 'package:settlenow/util/util_core.dart';
import 'package:uuid/uuid.dart';

class AuthModel {
  bool hasData = true;
  String refreshToken = "";
  String accessToken = "";
  String deviceId = "";
  String deviceType = "";

  AuthModel({
    this.hasData = true,
    required this.refreshToken,
    required this.accessToken,
    required this.deviceId,
  }) {
    deviceType = kIsWeb ? "web" : "mobile";
  }

  AuthModel.empty({this.hasData = false}) {
    deviceType = kIsWeb ? "web" : "mobile";
  }

  AuthModel generateNewDeviceID() {
    String newDeviceID = Uuid().v4();
    AuthModel newAuthData = copyWith(deviceId: newDeviceID);
    return newAuthData;
  }

  Future<void> persist() async {
    await Future.wait([
      TokenStorage.setAccessToken(accessToken),
      TokenStorage.setRefreshToken(refreshToken),
      TokenStorage.setDeviceId(deviceId),
    ]);
  }

  Future<void> revoke() async {
    refreshToken = "";
    accessToken = "";

    await Future.wait([
      TokenStorage.deleteAccessToken(),
      TokenStorage.deleteRefreshToken(),
    ]);
  }

  AuthModel fromMap(Map<String, dynamic> data) {
    return AuthModel(
      refreshToken: data["refresh_token"] ?? refreshToken,
      accessToken: data["access_token"] ?? accessToken,
      deviceId: data["device_id"] ?? deviceId,
    );
  }

  AuthModel copyWith({
    String? refreshToken,
    String? accessToken,
    String? deviceId,
  }) {
    return AuthModel(
      refreshToken: refreshToken ?? this.refreshToken,
      accessToken: accessToken ?? this.accessToken,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  @override
  String toString() {
    return 'AuthModel(HasData: $hasData, Device-ID: $deviceId, Device-Type: $deviceType)';
  }
}
