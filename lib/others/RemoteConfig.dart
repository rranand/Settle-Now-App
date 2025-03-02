import 'dart:async';
import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:settlenow/constant/RemoteConfigConstant.dart';

class RemoteConfigService {
  static FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  static Future<void> initRemoteConfig() async {
    remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: Duration(seconds: 10),
      minimumFetchInterval: Duration(hours: 1),
    ));
    await remoteConfig.setDefaults({
      RemoteConfigConstant.HIDE_PHONE_NO_CONSTANT: true,
      RemoteConfigConstant.SHARE_MESSAGE_CONSTANT: "{}",
      RemoteConfigConstant.EXPENSE_CATEGORY_CONSTANT: "{}",
      RemoteConfigConstant.VERSION_INFO_CONSTANT: "{}",
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
