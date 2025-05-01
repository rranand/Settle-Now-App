part of 'room_bloc.dart';

@immutable
sealed class RoomState {}

final class RoomInitial extends RoomState {}

final class RoomLoading extends RoomState {}

final class RoomFetchSuccess extends RoomState {
  final List<TransactionModel> data;

  RoomFetchSuccess(this.data);
}

final class RoomFailure extends RoomState {
  final String error;

  RoomFailure(this.error);
}
