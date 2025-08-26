import 'package:flutter/material.dart';
import 'package:settlenow_v2/model/preference_model.dart';

class PreferenceProvider extends ChangeNotifier {
  PreferenceModel _preferenceData = PreferenceModel.empty();

  ThemeMode get getTheme {
    switch (_preferenceData.theme) {
      case "dark":
        return ThemeMode.dark;
      case "light":
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  PreferenceSection get roomPref => _preferenceData.room;
  PreferenceSection get quicksplitPref => _preferenceData.quicksplit;
  PreferenceSection get lendenPref => _preferenceData.lenden;
  PreferenceModel get pref => _preferenceData;

  void updatePref(PreferenceModel newData) {
    _preferenceData = newData;
    notifyListeners();
  }
}
