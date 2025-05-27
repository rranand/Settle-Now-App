import 'package:shared_preferences/shared_preferences.dart';

class StaticVariables {
  static SharedPreferences? prefs;
}

Future<void> getSharedPrefInstance() async {
  StaticVariables.prefs ??= await SharedPreferences.getInstance();
}

Future<void> setBoolPrefs(String prefKey, bool prefValue) async {
  await getSharedPrefInstance();
  await StaticVariables.prefs!.setBool(prefKey, prefValue);
}

Future<bool?> getBoolPrefs(String prefKey) async {
  await getSharedPrefInstance();
  return StaticVariables.prefs!.getBool(prefKey);
}

Future<bool> getBoardingStatus() async {
  await getSharedPrefInstance();
  var isOnBoardingCompleted = StaticVariables.prefs!.getBool(
    'isOnBoardingCompleted',
  );
  if (isOnBoardingCompleted != null) {
    return isOnBoardingCompleted;
  } else {
    await StaticVariables.prefs!.setBool('isOnBoardingCompleted', false);
    return false;
  }
}

Future<bool> getInvitePermissionPoppedStatus() async {
  await getSharedPrefInstance();
  var isInvitePremissionPoppedProvided = StaticVariables.prefs!.getBool(
    'isInvitePremissionPoppedProvided',
  );
  if (isInvitePremissionPoppedProvided != null) {
    return isInvitePremissionPoppedProvided;
  } else {
    await StaticVariables.prefs!.setBool(
      'isInvitePremissionPoppedProvided',
      false,
    );
    return false;
  }
}

Future<bool> getNotificationPermissionPoppedStatus() async {
  await getSharedPrefInstance();
  var isNotificationPremissionPoppedProvided = StaticVariables.prefs!.getBool(
    'isNotificationPremissionPoppedProvided',
  );
  if (isNotificationPremissionPoppedProvided != null) {
    return isNotificationPremissionPoppedProvided;
  } else {
    await StaticVariables.prefs!.setBool(
      'isNotificationPremissionPoppedProvided',
      false,
    );
    return false;
  }
}

Future<String?> getStringPref(String prefKey) async {
  await getSharedPrefInstance();
  var token = StaticVariables.prefs!.getString(prefKey);
  return token;
}

Future<void> setStringPref(String tokenType, String token) async {
  await getSharedPrefInstance();
  await StaticVariables.prefs!.setString(tokenType, token);
}

Future<int?> getIntPref(String prefKey) async {
  await getSharedPrefInstance();
  var token = StaticVariables.prefs!.getInt(prefKey);
  return token;
}

Future<void> setIntPref(String tokenType, int token) async {
  await getSharedPrefInstance();
  await StaticVariables.prefs!.setInt(tokenType, token);
}

Future<void> removePref(List<String> prefKeys) async {
  await getSharedPrefInstance();
  List<Future> futures = [];
  for (String each in prefKeys) {
    futures.add(StaticVariables.prefs!.remove(each));
  }
  await Future.wait(futures);
}
