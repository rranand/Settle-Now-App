import 'package:flutter/foundation.dart';

class ThemeProvider extends ChangeNotifier {
  bool _darkTheme = false;

  bool get isDarkTheme => _darkTheme;

  void toggleTheme(bool flag) {
    _darkTheme = flag;
    notifyListeners();
  }
}
