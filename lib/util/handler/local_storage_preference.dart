import 'package:shared_preferences/shared_preferences.dart';

class LocalStoragePreference {
  static SharedPreferences? prefs;

  static Future<void> getSharedPrefInstance() async {
    LocalStoragePreference.prefs ??= await SharedPreferences.getInstance();
  }

  static Future<void> setBoolPrefs(String prefKey, bool prefValue) async {
    await getSharedPrefInstance();
    await LocalStoragePreference.prefs!.setBool(prefKey, prefValue);
  }

  static Future<bool?> getBoolPrefs(String prefKey) async {
    await getSharedPrefInstance();
    return LocalStoragePreference.prefs!.getBool(prefKey);
  }

  static Future<bool> getBoardingStatus() async {
    await getSharedPrefInstance();
    var isOnBoardingCompleted = LocalStoragePreference.prefs!.getBool(
      'isOnBoardingCompleted',
    );
    if (isOnBoardingCompleted != null) {
      return isOnBoardingCompleted;
    } else {
      await LocalStoragePreference.prefs!.setBool(
        'isOnBoardingCompleted',
        false,
      );
      return false;
    }
  }

  static Future<bool> getInvitePermissionPoppedStatus() async {
    await getSharedPrefInstance();
    var isInvitePremissionPoppedProvided = LocalStoragePreference.prefs!
        .getBool('isInvitePremissionPoppedProvided');
    if (isInvitePremissionPoppedProvided != null) {
      return isInvitePremissionPoppedProvided;
    } else {
      await LocalStoragePreference.prefs!.setBool(
        'isInvitePremissionPoppedProvided',
        false,
      );
      return false;
    }
  }

  static Future<bool> getNotificationPermissionPoppedStatus() async {
    await getSharedPrefInstance();
    var isNotificationPremissionPoppedProvided = LocalStoragePreference.prefs!
        .getBool('isNotificationPremissionPoppedProvided');
    if (isNotificationPremissionPoppedProvided != null) {
      return isNotificationPremissionPoppedProvided;
    } else {
      await LocalStoragePreference.prefs!.setBool(
        'isNotificationPremissionPoppedProvided',
        false,
      );
      return false;
    }
  }

  static Future<String?> getStringPref(String prefKey) async {
    await getSharedPrefInstance();
    var token = LocalStoragePreference.prefs!.getString(prefKey);
    return token;
  }

  static Future<void> setStringPref(String tokenType, String token) async {
    await getSharedPrefInstance();
    await LocalStoragePreference.prefs!.setString(tokenType, token);
  }

  static Future<int?> getIntPref(String prefKey) async {
    await getSharedPrefInstance();
    var token = LocalStoragePreference.prefs!.getInt(prefKey);
    return token;
  }

  static Future<void> setIntPref(String tokenType, int token) async {
    await getSharedPrefInstance();
    await LocalStoragePreference.prefs!.setInt(tokenType, token);
  }

  static Future<void> removePref(List<String> prefKeys) async {
    await getSharedPrefInstance();
    List<Future> futures = [];
    for (String each in prefKeys) {
      futures.add(LocalStoragePreference.prefs!.remove(each));
    }
    await Future.wait(futures);
  }

  static Future<void> clearAllPreferences() async {
    await getSharedPrefInstance();
    await LocalStoragePreference.prefs!.clear();
  }
}
