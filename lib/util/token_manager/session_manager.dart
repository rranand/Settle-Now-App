import 'dart:convert';

import 'package:settlenow/constant/api_constant.dart';
import 'package:settlenow/data/data_provider/auth_data_provider.dart';
import 'package:settlenow/model/auth_model.dart';
import 'package:settlenow/util/token_manager/auth_event_bus.dart';
import 'package:settlenow/util/token_manager/token_storage.dart';

class SessionManager {
  SessionManager._();
  static final SessionManager instance = SessionManager._();

  AuthModel _authData = AuthModel.empty();

  Future<String>? _refreshFuture;

  Future<void> initialize() async {
    if (_authData.hasData) {
      return;
    }
    _authData = await TokenStorage.getAuthData();

    if (_authData.deviceId.isEmpty) {
      AuthModel newAuthData = _authData.generateNewDeviceID();
      await SessionManager.instance.setAuth(newAuthData);
    }
  }

  Future<void> setAuth(AuthModel authData) async {
    _authData = authData;
    await authData.persist();
  }

  AuthModel getAuth() => _authData;

  Map<String, String> get authHeaders {
    Map<String, String> authHeaders = {};

    final deviceId = _authData.deviceId;

    if (deviceId.isNotEmpty) {
      authHeaders.putIfAbsent('X-Device-ID', () => deviceId);
    }

    final deviceType = _authData.deviceType;
    if (deviceType.isNotEmpty) {
      authHeaders.putIfAbsent('X-Device-Type', () => deviceType);
    }

    return authHeaders;
  }

  Future<String?> getValidAccessToken() async {
    if (_authData.accessToken.isEmpty) {
      return null;
    }

    if (!_isExpired(_authData.accessToken)) {
      return _authData.accessToken;
    }

    if (_refreshFuture != null) return await _refreshFuture;

    _refreshFuture = _doRefresh();

    try {
      final newToken = await _refreshFuture;
      return newToken;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<void> revoke() async {
    await _authData.revoke();
  }

  Future<String> _doRefresh() async {
    try {
      final authDataProvider = AuthDataProvider();
      return await authDataProvider.refreshToken();
    } catch (e) {
      if (e.toString() == ApiConstant.sessionExpired) {
        AuthEventBus.instance.emitSessionExpired();
      }
      rethrow;
    }
  }

  bool _isExpired(String token) {
    if (token.isEmpty) return true;
    final parts = token.split('.');
    if (parts.length != 3) return true;
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    final exp = payload['exp'] as int;
    return DateTime.now().millisecondsSinceEpoch / 1000 > exp - 30;
  }
}
