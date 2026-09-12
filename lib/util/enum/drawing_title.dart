import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

enum DrawingTitle {
  profile,
  preference,
  bankTransactions,
  getNotified,
  share,
  aboutUs,
  rateUs,
  logOut,
}

extension DrawingTitleExt on DrawingTitle {
  String get label {
    switch (this) {
      case DrawingTitle.profile:
        return 'Profile';
      case DrawingTitle.preference:
        return 'Preference';
      case DrawingTitle.bankTransactions:
        return 'Bank Transactions';
      case DrawingTitle.getNotified:
        return 'Get Notified';
      case DrawingTitle.share:
        return 'Share';
      case DrawingTitle.aboutUs:
        return 'About Us';
      case DrawingTitle.rateUs:
        return 'Rate Us';
      case DrawingTitle.logOut:
        return 'Log Out';
    }
  }

  bool get isWebCompatible {
    switch (this) {
      case DrawingTitle.getNotified:
      case DrawingTitle.bankTransactions:
      case DrawingTitle.share:
      case DrawingTitle.rateUs:
        return false;
      default:
        return true;
    }
  }

  bool get isBeta {
    switch (this) {
      case DrawingTitle.bankTransactions:
        return true;
      default:
        return false;
    }
  }
}

extension DrawingTitleIcon on DrawingTitle {
  IconData get icon {
    switch (this) {
      case DrawingTitle.profile:
        return Iconsax.profile_2user_copy;
      case DrawingTitle.preference:
        return Iconsax.setting_4_copy;
      case DrawingTitle.bankTransactions:
        return Iconsax.bank_copy;
      case DrawingTitle.getNotified:
        return Icons.notifications_active_outlined;
      case DrawingTitle.share:
        return Iconsax.share_copy;
      case DrawingTitle.aboutUs:
        return Iconsax.archive_book_copy;
      case DrawingTitle.rateUs:
        return Iconsax.star_copy;
      case DrawingTitle.logOut:
        return Iconsax.logout_copy;
    }
  }
}
