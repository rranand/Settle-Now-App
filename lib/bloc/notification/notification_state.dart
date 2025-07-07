part of 'notification_bloc.dart';

@immutable
sealed class NotificationState {}

final class NotificationInitial extends NotificationState {}

final class NotificationLoading extends NotificationState {}

final class NotificationFetchSuccess extends NotificationState {
  final List<NotificationModel> data;

  NotificationFetchSuccess(this.data);
}

final class NotificationFailure extends NotificationState {
  final String error;

  NotificationFailure(this.error);
}
