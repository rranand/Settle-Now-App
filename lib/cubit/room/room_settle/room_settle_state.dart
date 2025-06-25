part of 'room_settle_cubit.dart';

@immutable
sealed class RoomSettleState {}

final class RoomSettleInitial extends RoomSettleState {}

final class RoomSettleLoading extends RoomSettleState {}

final class RoomSettleSuccess extends RoomSettleState {
  final String id;
  final List<RoomSettleModel> data;

  RoomSettleSuccess(this.id, this.data);
}

final class RoomSettleFailure extends RoomSettleState {
  final String error;

  RoomSettleFailure(this.error);
}
