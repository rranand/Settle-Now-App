part of 'room_bloc.dart';

@immutable
sealed class RoomState {
  final bool hasData;

  const RoomState({this.hasData = false});
}

final class RoomInitial extends RoomState {
  const RoomInitial() : super(hasData: false);
}

final class RoomLoading extends RoomState {
  const RoomLoading() : super(hasData: false);
}

final class RoomFetchSuccess extends RoomState {
  final List<RoomInfoModel> data;

  const RoomFetchSuccess(this.data) : super(hasData: true);
}

final class RoomFailure extends RoomState {
  final String error;

  const RoomFailure(this.error);
}
