part of 'room_dashboard_bloc.dart';

@immutable
sealed class RoomDashboardEvent {}

final class RoomDashboardFetch extends RoomDashboardEvent {}
