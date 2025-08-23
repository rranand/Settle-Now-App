import 'dart:async';
import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/constant/remote_config_constant.dart';

class FirebaseRemote extends ChangeNotifier {
  final FirebaseRemoteConfig _remoteConfig;
  Timer? _refreshTimer;

  FirebaseRemote._internal(this._remoteConfig) {
    _startPeriodicRefresh();
  }

  static Future<FirebaseRemote> create() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval:
            kDebugMode ? const Duration(seconds: 0) : const Duration(hours: 1),
      ),
    );

    await remoteConfig.setDefaults({
      RemoteConfigConstant.shareMessageConstant:
          RemoteConfigValueConstant.shareMessageValueConstant,
      RemoteConfigConstant.versionInfoConstant:
          RemoteConfigValueConstant.versionInfoValueConstant,
    });

    await remoteConfig.fetchAndActivate();

    return FirebaseRemote._internal(remoteConfig);
  }

  Future<void> refresh() async {
    bool updated = await _remoteConfig.fetchAndActivate();
    if (updated) {
      notifyListeners();
    }
  }

  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 20), (_) async {
      await refresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  String getString(String key) {
    return _remoteConfig.getString(key);
  }

  bool getBool(String key) {
    return _remoteConfig.getBool(key);
  }

  Map<String, dynamic> getJSON(String key) {
    String jsonString = _remoteConfig.getString(key);
    if (jsonString.isEmpty || jsonString == "null") return {};
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      return {};
    }
  }
}
