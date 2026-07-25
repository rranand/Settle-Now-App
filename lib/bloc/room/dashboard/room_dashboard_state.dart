part of 'room_dashboard_bloc.dart';

@immutable
sealed class RoomDashboardState {}

final class RoomDashboardInitial extends RoomDashboardState {}

final class RoomDashboardLoading extends RoomDashboardState {}

final class RoomDashboardFetchSuccess extends RoomDashboardState {
  final bool activeHasMoreData;
  final bool inactiveHasMoreData;
  final List<RoomInfoModel> activeData;
  final List<RoomInfoModel> inactiveData;

  RoomDashboardFetchSuccess({
    required this.activeHasMoreData,
    required this.inactiveHasMoreData,
    required this.activeData,
    required this.inactiveData,
  });
}

final class RoomDashboardFailure extends RoomDashboardState {
  final String error;

  RoomDashboardFailure(this.error);
}
