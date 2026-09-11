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
  loginActivity;

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
    }
  }

  static NotificationType fromValue(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Unknown notification type: $value'),
    );
  }
}
