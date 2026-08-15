part of 'create_join_room_cubit.dart';

@immutable
sealed class CreateJoinRoomState {}

final class CreateJoinRoomInitial extends CreateJoinRoomState {}

final class CreateJoinRoomLoading extends CreateJoinRoomState {}

final class CreateJoinRoomSuccess extends CreateJoinRoomState {}

final class CreateJoinRoomFailure extends CreateJoinRoomState {
  final String error;

  CreateJoinRoomFailure({required this.error});
}
