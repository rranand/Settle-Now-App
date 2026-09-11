part of 'activity_notification_bloc.dart';

@immutable
sealed class ActivityNotificationState {}

final class ActivityNotificationInitial extends ActivityNotificationState {}

final class ActivityNotificationLoading extends ActivityNotificationState {}

final class ActivityNotificationFetchSuccess extends ActivityNotificationState {
  final LinkedHashMap<String, ActivityNotificationModel> data;
  final List<ActivityNotificationModel> dataList;
  final bool hasMoreData;
  final bool isLoadingMore;
  final String? error;

  ActivityNotificationFetchSuccess({
    required this.data,
    required this.hasMoreData,
    this.isLoadingMore = false,
    this.error,
  }) : dataList = data.values.toList();

  ActivityNotificationFetchSuccess copyWith({
    LinkedHashMap<String, ActivityNotificationModel>? data,
    bool? hasMoreData,
    bool? isLoadingMore,
    String? error,
  }) {
    return ActivityNotificationFetchSuccess(
      data: data ?? this.data,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

final class ActivityNotificationFailure extends ActivityNotificationState {
  final String error;

  ActivityNotificationFailure({required this.error});
}
