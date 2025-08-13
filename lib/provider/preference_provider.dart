import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:settlenow_v2/model/preference_model.dart';

class PreferenceProvider extends ChangeNotifier {
  PreferenceModel _preferenceData = PreferenceModel.empty();

  bool isDarkTheme(BuildContext context) {
    if (_preferenceData.theme == "system") {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    } else {
      return _preferenceData.theme == "dark";
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
