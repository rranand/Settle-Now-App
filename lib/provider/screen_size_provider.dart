import 'dart:math';

import 'package:flutter/material.dart';

class ScreenSizeProvider extends ChangeNotifier {
  EdgeInsets _padding = EdgeInsets.zero;

  EdgeInsets get getPadding => _padding;

  void calculatePadding(
    double screenWidth,
    double screenHeight,
    Orientation orientation,
    EdgeInsets viewInsets,
  ) async {
    await Future.delayed(Duration.zero);
    bool isLandscape = orientation == Orientation.landscape;
    double minLength = max(min(screenWidth, screenHeight), 0);
    double notchPadding = max(0, max(viewInsets.left, viewInsets.right));

    if (screenWidth <= 500 || minLength <= 500) {
      _padding = EdgeInsets.symmetric(
        horizontal: 12 + (isLandscape ? notchPadding : 0),
      );
    } else if (screenWidth <= 900) {
      _padding = EdgeInsets.symmetric(horizontal: 50);
    } else {
      _padding = EdgeInsets.symmetric(horizontal: (screenWidth - 800) * .5);
    }
    notifyListeners();
  }
}
