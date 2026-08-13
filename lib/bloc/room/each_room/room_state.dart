part of 'room_bloc.dart';

@immutable
sealed class RoomState {}

final class RoomInitial extends RoomState {}

final class RoomLoading extends RoomState {
  final String id;

  RoomLoading({required this.id});
}

final class RoomFetchSuccess extends RoomState {
  final String id;
  final List<RoomTransactionModel> data;
  final bool hasMoreData;

  RoomFetchSuccess({
    required this.id,
    required this.data,
    required this.hasMoreData,
  });
}

final class RoomFailure extends RoomState {
  final String error;

  RoomFailure({required this.error});
}
