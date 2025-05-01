part of 'lenden_dashboard_bloc.dart';

@immutable
sealed class LendenDashboardState {}

final class LendenDashboardInitial extends LendenDashboardState {}

final class LendenDashboardLoading extends LendenDashboardState {}

final class LendenDashboardFetchSuccess extends LendenDashboardState {
  final List<LendenDashboardModel> data;

  LendenDashboardFetchSuccess(this.data);
}

final class LendenDashboardFailure extends LendenDashboardState {
  final String error;

  LendenDashboardFailure(this.error);
}
