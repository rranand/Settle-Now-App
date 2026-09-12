import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

enum BottomNavigationType { home, quicksplit, personal, lenden, notification }

extension BottomNavigationTypeExt on BottomNavigationType {
  String get label {
    switch (this) {
      case BottomNavigationType.home:
        return 'Home';
      case BottomNavigationType.quicksplit:
        return 'Quick Split';
      case BottomNavigationType.personal:
        return 'Personal';
      case BottomNavigationType.lenden:
        return 'Len-Den';
      case BottomNavigationType.notification:
        return 'Notification';
    }
  }

  IconData get icon {
    switch (this) {
      case BottomNavigationType.home:
        return Iconsax.home_copy;
      case BottomNavigationType.quicksplit:
        return Iconsax.flash_copy;
      case BottomNavigationType.personal:
        return Iconsax.wallet_1_copy;
      case BottomNavigationType.lenden:
        return Iconsax.money_change_copy;
      case BottomNavigationType.notification:
        return Iconsax.notification_copy;
    }
  }

  bool get isSearchEnabled {
    switch (this) {
      case BottomNavigationType.notification:
        return false;
      default:
        return true;
    }
  }
}
