part of 'lenden_room_bloc.dart';

@immutable
sealed class LendenRoomState {}

final class LendenRoomInitial extends LendenRoomState {}

final class LendenRoomLoading extends LendenRoomState {}

final class LendenRoomFetchSuccess extends LendenRoomState {
  final String id;
  final LendenDashboardModel roomData;
  final List<LendenTransactionModel> data;
  final bool hasMoreData;
  final FetchStatus fetchStatus;

  LendenRoomFetchSuccess({
    required this.id,
    required this.roomData,
    required this.data,
    required this.hasMoreData,
    required this.fetchStatus,
  });
}

final class LendenRoomFailure extends LendenRoomState {
  final String error;

  LendenRoomFailure({required this.error});
}
