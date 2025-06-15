part of 'lenden_room_bloc.dart';

@immutable
sealed class LendenRoomState {}

final class LendenRoomInitial extends LendenRoomState {}

final class LendenRoomLoading extends LendenRoomState {}

final class LendenRoomFetchSuccess extends LendenRoomState {
  final String id;
  final LendenDashboardModel roomData;
  final List<LendenTransactionModel> data;

  LendenRoomFetchSuccess(this.id, this.roomData, this.data);
}

final class LendenRoomFailure extends LendenRoomState {
  final String error;

  LendenRoomFailure(this.error);
}
