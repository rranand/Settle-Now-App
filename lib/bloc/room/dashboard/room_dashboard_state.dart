part of 'room_dashboard_bloc.dart';

@immutable
sealed class RoomDashboardState {}

final class RoomDashboardInitial extends RoomDashboardState {}

final class RoomDashboardLoading extends RoomDashboardState {}

final class RoomDashboardFetchSuccess extends RoomDashboardState {
  final RoomDashboardModel activeRoomDashboardModel;
  final RoomDashboardModel inactiveRoomDashboardModel;
  final String? error;

  RoomDashboardFetchSuccess({
    required this.activeRoomDashboardModel,
    required this.inactiveRoomDashboardModel,
    this.error,
  });

  RoomDashboardFetchSuccess copyWith({
    RoomDashboardModel? activeRoomDashboardModel,
    RoomDashboardModel? inactiveRoomDashboardModel,
    String? error,
  }) {
    return RoomDashboardFetchSuccess(
      activeRoomDashboardModel:
          activeRoomDashboardModel ?? this.activeRoomDashboardModel,
      inactiveRoomDashboardModel:
          inactiveRoomDashboardModel ?? this.inactiveRoomDashboardModel,
      error: error,
    );
  }
}

final class RoomDashboardFailure extends RoomDashboardState {
  final String error;

  RoomDashboardFailure({required this.error});
}
