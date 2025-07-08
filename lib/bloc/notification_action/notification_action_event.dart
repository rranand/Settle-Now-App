part of 'notification_action_bloc.dart';

@immutable
sealed class NotificationActionEvent {}

class NotificationActionAcceptRequested extends NotificationActionEvent {
  final String id;
  final String authToken;

  NotificationActionAcceptRequested({
    required this.id,
    required this.authToken,
  });
}

class NotificationActionDeclineRequested extends NotificationActionEvent {
  final String id;
  final String authToken;

  NotificationActionDeclineRequested({
    required this.id,
    required this.authToken,
  });
}
