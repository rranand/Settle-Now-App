part of 'room_user_cubit.dart';

@immutable
sealed class RoomUserState {}

final class RoomUserInitial extends RoomUserState {}

final class RoomUserLoading extends RoomUserState {}

final class RoomUserSuccess extends RoomUserState {
  final List<RoomUserModel> data;

  RoomUserSuccess(this.data);
}

final class RoomUserFailure extends RoomUserState {
  final String error;

  RoomUserFailure(this.error);
}
