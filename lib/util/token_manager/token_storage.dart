import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:settlenow/model/auth_model.dart';

import 'token_storage_web.dart'
    if (dart.library.io) 'token_storage_stub.dart'
    as web_storage;

class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _deviceIdKey = 'device_id';

  static const _secureStorage = FlutterSecureStorage();

  static Future<void> setAccessToken(String token) async {
    if (kIsWeb) {
      web_storage.setItem(_accessTokenKey, token);
    } else {
      await _secureStorage.write(key: _accessTokenKey, value: token);
    }
  }

  static Future<String?> getAccessToken() async {
    if (kIsWeb) {
      return web_storage.getItem(_accessTokenKey);
    }
    return await _secureStorage.read(key: _accessTokenKey);
  }

  static Future<void> deleteAccessToken() async {
    if (kIsWeb) {
      web_storage.removeItem(_accessTokenKey);
    } else {
      await _secureStorage.delete(key: _accessTokenKey);
    }
  }

  // ---------------------------------------------------------------------------
  // REFRESH TOKEN
  // Web  → stored in HttpOnly cookie by server, not handled here.
  //        Flutter web never reads or writes the refresh token directly —
  //        the browser sends it automatically on every request.
  // Mobile → stored in FlutterSecureStorage, sent as X-Refresh-Token header.
  // ---------------------------------------------------------------------------

  static Future<void> setRefreshToken(String token) async {
    if (kIsWeb) {
      return;
    }
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  static Future<String?> getRefreshToken() async {
    if (kIsWeb) {
      return null;
    }
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  static Future<void> deleteRefreshToken() async {
    if (kIsWeb) {
      return;
    }
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  static Future<void> setDeviceId(String deviceId) async {
    if (kIsWeb) {
      web_storage.setItem(_deviceIdKey, deviceId);
    } else {
      await _secureStorage.write(key: _deviceIdKey, value: deviceId);
    }
  }

  static Future<String?> getDeviceId() async {
    if (kIsWeb) {
      return web_storage.getItem(_deviceIdKey);
    }
    return await _secureStorage.read(key: _deviceIdKey);
  }

  static Future<AuthModel> getAuthData() async {
    List<String?> tokens = await Future.wait([
      getRefreshToken(),
      getAccessToken(),
      getDeviceId(),
    ]);

    return AuthModel(
      refreshToken: tokens[0] ?? "",
      accessToken: tokens[1] ?? "",
      deviceId: tokens[2] ?? "",
    );
  }

  static Future<void> clearAll() async {
    if (kIsWeb) {
      web_storage.removeItem(_accessTokenKey);
      web_storage.removeItem(_deviceIdKey);
    } else {
      await _secureStorage.deleteAll();
    }
  }
}
