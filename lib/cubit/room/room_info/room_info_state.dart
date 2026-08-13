part of 'room_info_cubit.dart';

@immutable
sealed class RoomInfoState {}

final class RoomInfoInitial extends RoomInfoState {}

final class RoomInfoLoading extends RoomInfoState {}

final class RoomInfoSuccess extends RoomInfoState {
  final RoomInfoModel data;
  final bool isInternalUpdate;

  RoomInfoSuccess({required this.data, required this.isInternalUpdate});
}

final class RoomInfoFailure extends RoomInfoState {
  final String error;

  RoomInfoFailure(this.error);
}
