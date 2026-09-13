enum NotificationChannelType {
  room,
  quicksplit,
  lenden,
  account,
  miscellaneous,
}

NotificationChannelType notificationChannelTypeFromString(String type) {
  switch (type) {
    case 'roomID':
      return NotificationChannelType.room;
    case 'accountID':
      return NotificationChannelType.account;
    case 'quicksplitID':
      return NotificationChannelType.quicksplit;
    case 'lendenID':
      return NotificationChannelType.lenden;
    default:
      throw NotificationChannelType.miscellaneous;
  }
}

extension NotificationChannelTypeExt on NotificationChannelType {
  String get label {
    switch (this) {
      case NotificationChannelType.room:
        return 'Room';
      case NotificationChannelType.account:
        return 'Account';
      case NotificationChannelType.quicksplit:
        return 'Quick Split';
      case NotificationChannelType.lenden:
        return 'Lenden';
      case NotificationChannelType.miscellaneous:
        return 'Miscellaneous';
    }
  }
}
