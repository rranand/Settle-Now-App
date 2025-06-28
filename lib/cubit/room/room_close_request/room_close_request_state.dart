part of 'room_close_request_cubit.dart';

@immutable
sealed class RoomCloseRequestState {}

final class RoomCloseRequestInitial extends RoomCloseRequestState {}

final class RoomCloseRequestLoading extends RoomCloseRequestState {}

final class RoomCloseRequestSuccess extends RoomCloseRequestState {
  final String roomID;
  final int retryCount;
  RoomCloseRequestSuccess(this.roomID, this.retryCount);
}

final class RoomCloseRequestFailure extends RoomCloseRequestState {
  final String roomID;
  final String error;

  RoomCloseRequestFailure(this.roomID, this.error);
}
