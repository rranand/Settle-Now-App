import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

enum ActivityType {
  transactionAdded,
  transactionUpdated,
  transactionDeleted,
  settlementAdded,
  settlementUpdated,
  settlementDeleted,
  roomRenamed,
  memberAdded,
  memberRemoved,
  roomClosed,
  roomCreated,
}

ActivityType activityTypeFromApi(String type) {
  switch (type) {
    case 'TRANSACTION_ADDED':
      return ActivityType.transactionAdded;
    case 'TRANSACTION_UPDATED':
      return ActivityType.transactionUpdated;
    case 'TRANSACTION_DELETED':
      return ActivityType.transactionDeleted;
    case 'SETTLEMENT_ADDED':
      return ActivityType.settlementAdded;
    case 'SETTLEMENT_UPDATED':
      return ActivityType.settlementUpdated;
    case 'SETTLEMENT_DELETED':
      return ActivityType.settlementDeleted;
    case 'ROOM_RENAMED':
      return ActivityType.roomRenamed;
    case 'MEMBER_ADDED':
      return ActivityType.memberAdded;
    case 'MEMBER_REMOVED':
      return ActivityType.memberRemoved;
    case 'ROOM_CLOSED':
      return ActivityType.roomClosed;
    case 'ROOM_CREATED':
      return ActivityType.roomCreated;
    default:
      throw ArgumentError('Unknown ActivityType: $type');
  }
}

extension ActivityTypeExt on ActivityType {
  String get apiValue {
    switch (this) {
      case ActivityType.transactionAdded:
        return 'TRANSACTION_ADDED';
      case ActivityType.transactionUpdated:
        return 'TRANSACTION_UPDATED';
      case ActivityType.transactionDeleted:
        return 'TRANSACTION_DELETED';
      case ActivityType.settlementAdded:
        return 'SETTLEMENT_ADDED';
      case ActivityType.settlementUpdated:
        return 'SETTLEMENT_UPDATED';
      case ActivityType.settlementDeleted:
        return 'SETTLEMENT_DELETED';
      case ActivityType.roomRenamed:
        return 'ROOM_RENAMED';
      case ActivityType.memberAdded:
        return 'MEMBER_ADDED';
      case ActivityType.memberRemoved:
        return 'MEMBER_REMOVED';
      case ActivityType.roomClosed:
        return 'ROOM_CLOSED';
      case ActivityType.roomCreated:
        return 'ROOM_CREATED';
    }
  }

  String get label {
    switch (this) {
      case ActivityType.transactionAdded:
        return 'Transaction Added';
      case ActivityType.transactionUpdated:
        return 'Transaction Updated';
      case ActivityType.transactionDeleted:
        return 'Transaction Deleted';
      case ActivityType.settlementAdded:
        return 'Settlement Added';
      case ActivityType.settlementUpdated:
        return 'Settlement Updated';
      case ActivityType.settlementDeleted:
        return 'Settlement Deleted';
      case ActivityType.roomRenamed:
        return 'Room Renamed';
      case ActivityType.memberAdded:
        return 'Member Added';
      case ActivityType.memberRemoved:
        return 'Member Removed';
      case ActivityType.roomClosed:
        return 'Room Closed';
      case ActivityType.roomCreated:
        return 'Room Created';
    }
  }
}

extension ActivityTypeIcon on ActivityType {
  IconData get icon {
    switch (this) {
      case ActivityType.transactionAdded:
      case ActivityType.settlementAdded:
        return Iconsax.add_circle_copy;

      case ActivityType.transactionUpdated:
      case ActivityType.settlementUpdated:
      case ActivityType.roomRenamed:
        return Iconsax.edit_2_copy;

      case ActivityType.transactionDeleted:
      case ActivityType.settlementDeleted:
        return Icons.delete_outline;

      case ActivityType.memberAdded:
        return Iconsax.profile_add_copy;
      case ActivityType.memberRemoved:
        return Iconsax.profile_remove_copy;

      case ActivityType.roomClosed:
        return Iconsax.lock_copy;
      case ActivityType.roomCreated:
        return Iconsax.home_copy;
    }
  }
}

extension ActivityTypeIconCode on ActivityType {
  int get iconCode {
    switch (this) {
      case ActivityType.transactionAdded:
      case ActivityType.settlementAdded:
        return 0;

      case ActivityType.transactionUpdated:
      case ActivityType.settlementUpdated:
      case ActivityType.roomRenamed:
        return 1;

      case ActivityType.transactionDeleted:
      case ActivityType.settlementDeleted:
        return 2;

      case ActivityType.memberAdded:
        return 3;

      case ActivityType.memberRemoved:
        return 4;

      case ActivityType.roomClosed:
        return 5;

      case ActivityType.roomCreated:
        return 6;
    }
  }
}
