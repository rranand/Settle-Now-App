import 'package:flutter/material.dart';

class ScreenSizeProvider extends ChangeNotifier {
  EdgeInsets _padding = EdgeInsets.zero;

  EdgeInsets get getPadding => _padding;

  void calculatePadding(double screenWidth) {
    if (screenWidth <= 500) {
      _padding = EdgeInsets.symmetric(horizontal: 12);
    } else if (screenWidth <= 900) {
      _padding = EdgeInsets.symmetric(horizontal: 50);
    } else {
      _padding = EdgeInsets.symmetric(horizontal: (screenWidth - 800) * .5);
    }
  }
}
