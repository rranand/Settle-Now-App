part of 'room_settle_cubit.dart';

@immutable
sealed class RoomSettleState {}

final class RoomSettleInitial extends RoomSettleState {}

final class RoomSettleLoading extends RoomSettleState {}

final class RoomSettleSuccess extends RoomSettleState {
  final List<RoomSettleModel> data;

  RoomSettleSuccess(this.data);
}

final class RoomSettleFailure extends RoomSettleState {
  final String error;

  RoomSettleFailure(this.error);
}
