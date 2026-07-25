part of 'lenden_dashboard_bloc.dart';

@immutable
sealed class LendenDashboardState {}

final class LendenDashboardInitial extends LendenDashboardState {}

final class LendenDashboardLoading extends LendenDashboardState {}

final class LendenDashboardFetchSuccess extends LendenDashboardState {
  final List<LendenDashboardModel> data;
  final bool hasMoreData;

  LendenDashboardFetchSuccess({required this.data, required this.hasMoreData});
}

final class LendenDashboardFailure extends LendenDashboardState {
  final String error;

  LendenDashboardFailure({required this.error});
}
