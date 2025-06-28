part of 'room_close_cubit.dart';

@immutable
sealed class RoomCloseState {}

final class RoomCloseInitial extends RoomCloseState {}

final class RoomCloseLoading extends RoomCloseState {}

final class RoomCloseSuccess extends RoomCloseState {
  final String roomID;
  final int retryCount;
  RoomCloseSuccess(this.roomID, this.retryCount);
}

final class RoomCloseFailure extends RoomCloseState {
  final String roomID;
  final String error;

  RoomCloseFailure(this.roomID, this.error);
}
