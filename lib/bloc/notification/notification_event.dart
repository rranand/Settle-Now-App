part of 'notification_bloc.dart';

@immutable
sealed class NotificationEvent {}

final class NotificationFetch extends NotificationEvent {
  final String authToken;
  NotificationFetch({required this.authToken});
}

final class NotificationOnAdd extends NotificationEvent {
  final List<NotificationModel> data;
  NotificationOnAdd({required this.data});
}

final class NotificationOnDelete extends NotificationEvent {
  final String id;
  NotificationOnDelete({required this.id});
}

final class NotificationReset extends NotificationEvent {}
