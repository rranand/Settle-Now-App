part of 'personal_expense_dashboard_bloc.dart';

@immutable
sealed class PersonalExpenseDashboardState {}

final class PersonalExpenseDashboardInitial
    extends PersonalExpenseDashboardState {}

final class PersonalExpenseDashboardLoading
    extends PersonalExpenseDashboardState {}

final class PersonalExpenseDashboardFetchSuccess
    extends PersonalExpenseDashboardState {
  final LinkedHashMap<String, PersonalExpenseInfoModel> data;
  final List<PersonalExpenseInfoModel> dataList;
  final bool hasMoreData;
  final bool isLoadingMore;
  final String? error;

  PersonalExpenseDashboardFetchSuccess({
    required this.data,
    required this.hasMoreData,
    this.isLoadingMore = false,
    this.error,
  }) : dataList = data.values.toList();

  PersonalExpenseDashboardFetchSuccess copyWith({
    LinkedHashMap<String, PersonalExpenseInfoModel>? data,
    bool? hasMoreData,
    bool? isLoadingMore,
    String? error,
  }) {
    return PersonalExpenseDashboardFetchSuccess(
      data: data ?? this.data,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

final class PersonalExpenseDashboardFailure
    extends PersonalExpenseDashboardState {
  final String error;

  PersonalExpenseDashboardFailure({required this.error});
}
