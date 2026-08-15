part of 'room_close_request_cubit.dart';

@immutable
sealed class RoomCloseRequestState {}

final class RoomCloseRequestInitial extends RoomCloseRequestState {}

final class RoomCloseRequestLoading extends RoomCloseRequestState {}

final class RoomCloseRequestSuccess extends RoomCloseRequestState {
  final String roomID;
  final int retryCount;
  RoomCloseRequestSuccess({required this.roomID, required this.retryCount});
}

final class RoomCloseRequestFailure extends RoomCloseRequestState {
  final String roomID;
  final String error;

  RoomCloseRequestFailure({required this.roomID, required this.error});
}
