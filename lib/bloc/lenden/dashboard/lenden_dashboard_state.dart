part of 'lenden_dashboard_bloc.dart';

@immutable
sealed class LendenDashboardState {}

final class LendenDashboardInitial extends LendenDashboardState {}

final class LendenDashboardLoading extends LendenDashboardState {}

final class LendenDashboardFetchSuccess extends LendenDashboardState {
  final LinkedHashMap<String, LendenDashboardModel> data;
  final List<LendenDashboardModel> dataList;
  final bool hasMoreData;
  final bool isLoadingMore;
  final String? error;

  LendenDashboardFetchSuccess({
    required this.data,
    required this.hasMoreData,
    this.isLoadingMore = false,
    this.error,
  }) : dataList = data.values.toList();

  LendenDashboardFetchSuccess copyWith({
    LinkedHashMap<String, LendenDashboardModel>? data,
    bool? hasMoreData,
    bool? isLoadingMore,
    String? error,
  }) {
    return LendenDashboardFetchSuccess(
      data: data ?? this.data,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

final class LendenDashboardFailure extends LendenDashboardState {
  final String error;

  LendenDashboardFailure({required this.error});
}
