part of 'notification_bloc.dart';

@immutable
sealed class NotificationEvent {}

final class NotificationFetch extends NotificationEvent {
  final String authToken;
  NotificationFetch({required this.authToken});
}

final class NotificationOnAdd extends NotificationEvent {
  final NotificationModel data;
  NotificationOnAdd({required this.data});
}

final class NotificationOnUpdate extends NotificationEvent {
  final NotificationModel data;
  NotificationOnUpdate({required this.data});
}
