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
  final Map<String, List<ActivityModel>> transactionWiseActivity;
  final bool hasMoreData;

  RoomActivitySuccess({
    required this.id,
    required this.data,
    required this.transactionWiseActivity,
    required this.hasMoreData,
  });
}

final class RoomActivityFailure extends RoomActivityState {
  final String id;
  final String error;

  RoomActivityFailure({required this.id, required this.error});
}
