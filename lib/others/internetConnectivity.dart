import 'package:flutter/foundation.dart';

class InternetconnectivityProvider extends ChangeNotifier {
  bool alertSet = false;
  bool deviceConnected = true;

  bool get isAlertSet => !kIsWeb && alertSet;
  bool get isDeviceConnected => kIsWeb || deviceConnected;

  void toggleDeviceConnected(bool flag) {
    deviceConnected = flag;
    notifyListeners();
  }

  void toggleAlertSet(bool flag) {
    alertSet = flag;
    notifyListeners();
  }
}
