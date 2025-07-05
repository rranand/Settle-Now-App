part of 'room_dashboard_bloc.dart';

@immutable
sealed class RoomDashboardEvent {}

final class RoomDashboardFetch extends RoomDashboardEvent {
  final bool isActiveRoom;
  final String authToken;

  RoomDashboardFetch({required this.isActiveRoom, required this.authToken});
}

final class RoomDashboardOnAddNewRoom extends RoomDashboardEvent {
  final RoomInfoModel data;
  final bool isLoading;
  RoomDashboardOnAddNewRoom({required this.data, required this.isLoading});
}

final class RoomDashboardOnCloseRoom extends RoomDashboardEvent {
  final RoomInfoModel data;
  RoomDashboardOnCloseRoom({required this.data});
}
