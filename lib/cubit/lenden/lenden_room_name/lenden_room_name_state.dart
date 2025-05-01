part of 'lenden_room_name_cubit.dart';

@immutable
sealed class LendenRoomNameState {}

final class LendenRoomNameInitial extends LendenRoomNameState {}

final class LendenRoomNameLoading extends LendenRoomNameState {}

final class LendenRoomNameSuccess extends LendenRoomNameState {
  final String roomName;

  LendenRoomNameSuccess(this.roomName);
}

final class LendenRoomNameFailure extends LendenRoomNameState {
  final String error;

  LendenRoomNameFailure(this.error);
}
