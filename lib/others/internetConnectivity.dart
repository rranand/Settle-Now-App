import 'package:flutter/material.dart';

class InternetconnectivityProvider extends ChangeNotifier {
  bool alertSet = false;
  bool deviceConnected = true;

  bool get isAlertSet => alertSet;
  bool get isDeviceConnected => deviceConnected;

  void toggleDeviceConnected(bool flag) {
    deviceConnected = flag;
    notifyListeners();
  }

  void toggleAlertSet(bool flag) {
    alertSet = flag;
    notifyListeners();
  }
}
