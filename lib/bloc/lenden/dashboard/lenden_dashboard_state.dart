part of 'lenden_dashboard_bloc.dart';

@immutable
sealed class LendenDashboardState {
  final bool hasData;

  const LendenDashboardState({this.hasData = false});
}

final class LendenDashboardInitial extends LendenDashboardState {
  const LendenDashboardInitial() : super(hasData: false);
}

final class LendenDashboardLoading extends LendenDashboardState {
  const LendenDashboardLoading() : super(hasData: false);
}

final class LendenDashboardFetchSuccess extends LendenDashboardState {
  final List<LendenDashboardModel> data;

  const LendenDashboardFetchSuccess(this.data) : super(hasData: true);
}

final class LendenDashboardFailure extends LendenDashboardState {
  final String error;

  const LendenDashboardFailure(this.error) : super(hasData: false);
}
