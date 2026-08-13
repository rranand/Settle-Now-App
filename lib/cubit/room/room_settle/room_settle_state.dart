part of 'room_settle_cubit.dart';

@immutable
sealed class RoomSettleState {}

final class RoomSettleInitial extends RoomSettleState {}

final class RoomSettleLoading extends RoomSettleState {
  final String id;

  RoomSettleLoading({required this.id});
}

final class RoomSettleSuccess extends RoomSettleState {
  final String id;
  final List<RoomSettleModel> data;
  final bool hasMoreData;

  RoomSettleSuccess({
    required this.id,
    required this.data,
    required this.hasMoreData,
  });
}

final class RoomSettleFailure extends RoomSettleState {
  final String error;

  RoomSettleFailure({required this.error});
}
