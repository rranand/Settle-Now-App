import 'package:flutter/material.dart';

class CollectAnalytics extends ChangeNotifier {
  bool collectAnalytics = false;

  bool get collectAnalyticsEnabled => collectAnalytics;

  void toggleCollectAnalytics(bool flag) {
    collectAnalytics = flag;
    notifyListeners();
  }
}
