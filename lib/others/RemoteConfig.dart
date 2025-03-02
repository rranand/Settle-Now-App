import 'dart:async';
import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow/constant/RemoteConfigConstant.dart';

class RemoteConfigService {
  static FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  static Future<void> initRemoteConfig() async {
    remoteConfig = FirebaseRemoteConfig.instance;
    if (!kIsWeb) {
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: Duration(seconds: 10),
        minimumFetchInterval: Duration(hours: 1),
      ));
    }

    await remoteConfig.setDefaults({
      RemoteConfigConstant.HIDE_PHONE_NO_CONSTANT: true,
      RemoteConfigConstant.SHARE_MESSAGE_CONSTANT:
          RemoteConfigValueConstant.SHARE_MESSAGE_VALUE_CONSTANT,
      RemoteConfigConstant.EXPENSE_CATEGORY_CONSTANT:
          RemoteConfigValueConstant.EXPENSE_CATEGORY_VALUE_CONSTANT,
      RemoteConfigConstant.VERSION_INFO_CONSTANT:
          RemoteConfigValueConstant.VERSION_INFO_VALUE_CONSTANT,
      RemoteConfigConstant.COLLECT_FRONTEND_ANALYTICS_CONSTANT: false,
      RemoteConfigConstant.ENV_CONSTANT: "NONE"
    });

    await remoteConfig.fetchAndActivate();
  }

  static String getString(String key) {
    return remoteConfig.getString(key);
  }

  static bool getBool(String key) {
    return remoteConfig.getBool(key);
  }

  static Map<String, dynamic> getJSON(String key) {
    String jsonString = remoteConfig.getString(key);
    if (jsonString.isEmpty || jsonString == "null") return {};
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      return {};
    }
  }
}
