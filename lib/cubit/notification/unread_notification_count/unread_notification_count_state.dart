part of 'unread_notification_count_cubit.dart';

@immutable
sealed class UnreadNotificationCountState {}

final class UnreadNotificationCountInitial
    extends UnreadNotificationCountState {}

final class UnreadNotificationCountLoading
    extends UnreadNotificationCountState {}

final class UnreadNotificationCountSuccess
    extends UnreadNotificationCountState {
  final int count;

  UnreadNotificationCountSuccess({required this.count});
}

final class UnreadNotificationCountFailure
    extends UnreadNotificationCountState {
  final String error;

  UnreadNotificationCountFailure({required this.error});
}
