part of 'notification_action_bloc.dart';

@immutable
sealed class NotificationActionEvent {}

class NotificationActionAcceptRequested extends NotificationActionEvent {
  final String id;

  NotificationActionAcceptRequested({required this.id});
}

class NotificationActionDeclineRequested extends NotificationActionEvent {
  final String id;

  NotificationActionDeclineRequested({required this.id});
}

class NotificationActionReset extends NotificationActionEvent {}
