import 'dart:async';
import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow/constant/remote_config_constant.dart';

class FirebaseRemote extends ChangeNotifier {
  static final FirebaseRemoteConfig _remoteConfig =
      FirebaseRemoteConfig.instance;
  late final StreamSubscription<RemoteConfigUpdate> _updateSubscription;

  FirebaseRemote();

  Future<void> init() async {
    if (kIsWeb) {
      return;
    }
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval:
            kDebugMode ? const Duration(seconds: 0) : const Duration(hours: 1),
      ),
    );

    await _remoteConfig.setDefaults({
      RemoteConfigConstant.shareMessageConstant:
          RemoteConfigValueConstant.shareMessageValueConstant,
      RemoteConfigConstant.versionInfoConstant:
          RemoteConfigValueConstant.versionInfoValueConstant,
    });

    await _remoteConfig.fetchAndActivate();

    _listenForUpdates();
  }

  Future<void> refresh() async {
    bool updated = await _remoteConfig.fetchAndActivate();
    if (updated) {
      notifyListeners();
    }
  }

  void _listenForUpdates() {
    _updateSubscription = _remoteConfig.onConfigUpdated.listen((
      RemoteConfigUpdate event,
    ) async {
      await _remoteConfig.activate();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _updateSubscription.cancel();
    }
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
