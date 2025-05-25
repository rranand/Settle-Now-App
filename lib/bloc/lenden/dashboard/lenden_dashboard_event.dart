part of 'lenden_dashboard_bloc.dart';

@immutable
sealed class LendenDashboardEvent {}

final class LendenDashboardFetch extends LendenDashboardEvent {}

final class LendenDashboardOnAddNewRoom extends LendenDashboardEvent {
  final LendenDashboardModel data;
  final bool isLoading;
  LendenDashboardOnAddNewRoom({required this.data, required this.isLoading});
}
