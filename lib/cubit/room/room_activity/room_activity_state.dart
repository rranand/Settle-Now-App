part of 'room_activity_cubit.dart';

@immutable
sealed class RoomActivityState {}

final class RoomActivityInitial extends RoomActivityState {}

final class RoomActivityLoading extends RoomActivityState {
  final String id;
  RoomActivityLoading(this.id);
}

final class RoomActivitySuccess extends RoomActivityState {
  final String id;
  final List<ActivityModel> data;
  RoomActivitySuccess(this.id, this.data);
}

final class RoomActivityFailure extends RoomActivityState {
  final String id;
  final String error;

  RoomActivityFailure(this.id, this.error);
}
