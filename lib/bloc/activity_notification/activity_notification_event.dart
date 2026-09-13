part of 'activity_notification_bloc.dart';

@immutable
sealed class ActivityNotificationEvent {}

final class ActivityNotificationFetch extends ActivityNotificationEvent {
  final bool isFreshFetch;

  ActivityNotificationFetch({required this.isFreshFetch});
}

final class ActivityNotificationMarkAsRead extends ActivityNotificationEvent {
  final List<String> ids;

  ActivityNotificationMarkAsRead({required this.ids});
}

final class ActivityNotificationMarkAllAsRead
    extends ActivityNotificationEvent {
  final DateTime recentlyReadTimestamp;
  final ScaffoldMessengerState scaffoldMessenger;

  ActivityNotificationMarkAllAsRead({
    required this.scaffoldMessenger,
    required this.recentlyReadTimestamp,
  });
}

final class ActivityNotificationReset extends ActivityNotificationEvent {}
