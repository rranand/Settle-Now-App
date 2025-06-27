part of 'room_bloc.dart';

@immutable
sealed class RoomState {}

final class RoomInitial extends RoomState {}

final class RoomLoading extends RoomState {
  final String id;

  RoomLoading(this.id);
}

final class RoomFetchSuccess extends RoomState {
  final String id;
  final List<TransactionModel> data;

  RoomFetchSuccess(this.id, this.data);
}

final class RoomFailure extends RoomState {
  final String error;

  RoomFailure(this.error);
}
