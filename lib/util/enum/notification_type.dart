import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

enum NotificationType {
  transactionAdded,
  transactionUpdated,
  transactionDeleted,

  settlementAdded,
  settlementUpdated,
  settlementDeleted,

  memberInvited,
  memberJoinRequest,
  memberAdded,
  memberRemoved,

  roomRenamed,
  roomClosed,
  roomCloseRequest,

  loginVerification,
  loginActivity,

  unknown;

  String get value {
    switch (this) {
      case NotificationType.transactionAdded:
        return 'TRANSACTION_ADDED';
      case NotificationType.transactionUpdated:
        return 'TRANSACTION_UPDATED';
      case NotificationType.transactionDeleted:
        return 'TRANSACTION_DELETED';

      case NotificationType.settlementAdded:
        return 'SETTLEMENT_ADDED';
      case NotificationType.settlementUpdated:
        return 'SETTLEMENT_UPDATED';
      case NotificationType.settlementDeleted:
        return 'SETTLEMENT_DELETED';

      case NotificationType.memberInvited:
        return 'MEMBER_INVITED';
      case NotificationType.memberJoinRequest:
        return 'MEMBER_JOIN_REQUEST';
      case NotificationType.memberAdded:
        return 'MEMBER_ADDED';
      case NotificationType.memberRemoved:
        return 'MEMBER_REMOVED';

      case NotificationType.roomRenamed:
        return 'ROOM_RENAMED';
      case NotificationType.roomClosed:
        return 'ROOM_CLOSED';
      case NotificationType.roomCloseRequest:
        return 'ROOM_CLOSE_REQUEST';

      case NotificationType.loginVerification:
        return 'LOGIN_VERIFICATION';
      case NotificationType.loginActivity:
        return 'LOGIN_ACTIVITY';
      case NotificationType.unknown:
        return 'UNKNOWN';
    }
  }

  String get label {
    switch (this) {
      case NotificationType.transactionAdded:
        return 'Transaction Added';
      case NotificationType.transactionUpdated:
        return 'Transaction Updated';
      case NotificationType.transactionDeleted:
        return 'Transaction Deleted';

      case NotificationType.settlementAdded:
        return 'Settlement Added';
      case NotificationType.settlementUpdated:
        return 'Settlement Updated';
      case NotificationType.settlementDeleted:
        return 'Settlement Deleted';

      case NotificationType.memberInvited:
        return 'Member Invited';
      case NotificationType.memberJoinRequest:
        return 'Member Join Request';
      case NotificationType.memberAdded:
        return 'Member Added';
      case NotificationType.memberRemoved:
        return 'Member Removed';

      case NotificationType.roomRenamed:
        return 'Room Renamed';
      case NotificationType.roomClosed:
        return 'Room Closed';
      case NotificationType.roomCloseRequest:
        return 'Room Close Request';

      case NotificationType.loginVerification:
        return 'Login Verification';
      case NotificationType.loginActivity:
        return 'Login Activity';
      case NotificationType.unknown:
        return 'Unknown';
    }
  }

  static NotificationType fromValue(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.unknown,
    );
  }
}

extension NotificationTypeIcon on NotificationType {
  IconData get icon {
    switch (this) {
      case NotificationType.transactionAdded:
      case NotificationType.settlementAdded:
        return Iconsax.add_circle_copy;

      case NotificationType.transactionUpdated:
      case NotificationType.settlementUpdated:
      case NotificationType.roomRenamed:
        return Iconsax.edit_2_copy;

      case NotificationType.transactionDeleted:
      case NotificationType.settlementDeleted:
        return Icons.delete_outline;

      case NotificationType.memberAdded:
        return Iconsax.profile_add_copy;
      case NotificationType.memberRemoved:
        return Iconsax.profile_remove_copy;

      case NotificationType.roomClosed:
        return Iconsax.lock_copy;
      case NotificationType.roomCloseRequest:
        return Icons.campaign_outlined;
      default:
        return Iconsax.notification_copy;
    }
  }

  int get iconCode {
    switch (this) {
      case NotificationType.transactionAdded:
      case NotificationType.settlementAdded:
        return 0;

      case NotificationType.transactionUpdated:
      case NotificationType.settlementUpdated:
      case NotificationType.roomRenamed:
        return 1;

      case NotificationType.transactionDeleted:
      case NotificationType.settlementDeleted:
        return 2;

      case NotificationType.memberAdded:
        return 3;

      case NotificationType.memberRemoved:
        return 4;

      case NotificationType.roomClosed:
        return 5;

      case NotificationType.roomCloseRequest:
        return 6;
      default:
        return 7;
    }
  }
}
