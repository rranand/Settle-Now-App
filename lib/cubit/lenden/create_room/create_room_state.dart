part of 'create_room_cubit.dart';

@immutable
sealed class CreateRoomState {}

final class CreateRoomInitial extends CreateRoomState {}

final class CreateRoomSuccess extends CreateRoomState {}

final class CreateRoomFailure extends CreateRoomState {
  final String error;

  CreateRoomFailure(this.error);
}
