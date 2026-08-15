part of 'room_settle_upsert_cubit.dart';

@immutable
sealed class RoomSettleUpsertState {}

final class RoomSettleUpsertInitial extends RoomSettleUpsertState {}

final class RoomSettleUpsertLoading extends RoomSettleUpsertState {}

final class RoomSettleUpsertSuccess extends RoomSettleUpsertState {
  final RoomSettleModel data;

  RoomSettleUpsertSuccess({required this.data});
}

final class RoomSettleUpsertFailure extends RoomSettleUpsertState {
  final String error;

  RoomSettleUpsertFailure({required this.error});
}
