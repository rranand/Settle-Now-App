part of 'activity_notification_bloc.dart';

@immutable
sealed class ActivityNotificationEvent {}

final class ActivityNotificationFetch extends ActivityNotificationEvent {
  final bool isFreshFetch;

  ActivityNotificationFetch({required this.isFreshFetch});
}

final class ActivityNotificationMarkAsRead extends ActivityNotificationEvent {
  final Set<String> ids;

  ActivityNotificationMarkAsRead({required this.ids});
}

final class ActivityNotificationMarkAllAsRead
    extends ActivityNotificationEvent {
  final ScaffoldMessengerState scaffoldMessenger;

  ActivityNotificationMarkAllAsRead({required this.scaffoldMessenger});
}

final class ActivityNotificationReset extends ActivityNotificationEvent {}
