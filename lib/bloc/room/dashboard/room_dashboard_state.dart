part of 'room_dashboard_bloc.dart';

@immutable
sealed class RoomDashboardState {}

final class RoomDashboardInitial extends RoomDashboardState {}

final class RoomDashboardLoading extends RoomDashboardState {}

final class RoomDashboardFetchSuccess extends RoomDashboardState {
  final List<RoomInfoModel> data;

  RoomDashboardFetchSuccess(this.data);
}

final class RoomDashboardFailure extends RoomDashboardState {
  final String error;

  RoomDashboardFailure(this.error);
}
