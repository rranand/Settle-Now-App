import 'package:flutter/material.dart';
import 'package:settlenow/others/staticVar.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> getSharedPrefInstance() async {
  if (StaticVariables.prefs == null) {
    StaticVariables.prefs = await SharedPreferences.getInstance();
  }
}

Future<bool> getTheme(BuildContext context) async {
  await getSharedPrefInstance();
  var isDarkTheme = await StaticVariables.prefs!.getBool('darkTheme');
  if (isDarkTheme != null) {
    return isDarkTheme;
  } else {
    isDarkTheme = Brightness.dark == MediaQuery.of(context).platformBrightness;
    setBoolPrefs('darkTheme', isDarkTheme);
    return isDarkTheme;
  }
}

Future<void> setBoolPrefs(String prefKey, bool prefValue) async {
  await getSharedPrefInstance();
  await StaticVariables.prefs!.setBool(prefKey, prefValue);
}

Future<bool?> getBoolPrefs(String prefKey) async {
  await getSharedPrefInstance();
  return await StaticVariables.prefs!.getBool(prefKey);
}

Future<bool> getBoardingStatus() async {
  await getSharedPrefInstance();
  var isOnBoardingCompleted =
      await StaticVariables.prefs!.getBool('isOnBoardingCompleted');
  if (isOnBoardingCompleted != null) {
    return isOnBoardingCompleted;
  } else {
    await StaticVariables.prefs!.setBool('isOnBoardingCompleted', false);
    return false;
  }
}

Future<bool> getInvitePermissionStatus() async {
  await getSharedPrefInstance();
  var isInvitePremissionProvided =
      await StaticVariables.prefs!.getBool('isInvitePremissionProvided');
  if (isInvitePremissionProvided != null) {
    return isInvitePremissionProvided;
  } else {
    await StaticVariables.prefs!.setBool('isInvitePremissionProvided', false);
    return false;
  }
}

Future<String?> getStringPref(String prefKey) async {
  await getSharedPrefInstance();
  var token = await StaticVariables.prefs!.getString(prefKey);
  return token;
}

Future<void> setStringPref(String tokenType, String token) async {
  await getSharedPrefInstance();
  await StaticVariables.prefs!.setString(tokenType, token);
}

Future<int?> getIntPref(String prefKey) async {
  await getSharedPrefInstance();
  var token = await StaticVariables.prefs!.getInt(prefKey);
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
