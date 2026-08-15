part of 'room_activity_cubit.dart';

@immutable
sealed class RoomActivityState {}

final class RoomActivityInitial extends RoomActivityState {}

final class RoomActivityLoading extends RoomActivityState {
  final String id;
  RoomActivityLoading({required this.id});
}

final class RoomActivitySuccess extends RoomActivityState {
  final String id;
  final List<ActivityModel> data;
  final LinkedHashMap<String, List<ActivityModel>> transactionWiseActivity;
  final bool hasMoreData;
  final bool isLoadingMore;
  final String? error;

  RoomActivitySuccess({
    required this.id,
    required this.data,
    required this.transactionWiseActivity,
    required this.hasMoreData,
    this.isLoadingMore = false,
    this.error,
  });

  RoomActivitySuccess copyWith({
    String? id,
    List<ActivityModel>? data,
    LinkedHashMap<String, List<ActivityModel>>? transactionWiseActivity,
    bool? hasMoreData,
    bool? isLoadingMore,
    String? error,
  }) {
    return RoomActivitySuccess(
      id: id ?? this.id,
      data: data ?? this.data,
      transactionWiseActivity:
          transactionWiseActivity ?? this.transactionWiseActivity,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

final class RoomActivityFailure extends RoomActivityState {
  final String id;
  final String error;

  RoomActivityFailure({required this.id, required this.error});
}
