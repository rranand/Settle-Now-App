part of 'room_dashboard_bloc.dart';

@immutable
sealed class RoomDashboardState {}

final class RoomDashboardInitial extends RoomDashboardState {}

final class RoomDashboardLoading extends RoomDashboardState {}

final class RoomDashboardFetchSuccess extends RoomDashboardState {
  final FetchStatus activeStatus;
  final FetchStatus inactiveStatus;
  final List<RoomInfoModel> activeData;
  final List<RoomInfoModel> inactiveData;

  RoomDashboardFetchSuccess({
    required this.activeStatus,
    required this.inactiveStatus,
    required this.activeData,
    required this.inactiveData,
  });
}

final class RoomDashboardFailure extends RoomDashboardState {
  final String error;

  RoomDashboardFailure(this.error);
}
