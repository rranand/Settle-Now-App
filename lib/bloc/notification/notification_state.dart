part of 'notification_bloc.dart';

@immutable
sealed class NotificationState {}

final class NotificationInitial extends NotificationState {}

final class NotificationLoading extends NotificationState {}

final class NotificationFetchSuccess extends NotificationState {
  final LinkedHashMap<String, NotificationModel> data;
  final List<NotificationModel> dataList;

  NotificationFetchSuccess({required this.data})
    : dataList = data.values.toList();
}

final class NotificationFailure extends NotificationState {
  final String error;

  NotificationFailure({required this.error});
}
