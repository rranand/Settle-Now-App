part of 'personal_expense_dashboard_bloc.dart';

@immutable
sealed class PersonalExpenseDashboardState {}

final class PersonalExpenseDashboardInitial
    extends PersonalExpenseDashboardState {}

final class PersonalExpenseDashboardLoading
    extends PersonalExpenseDashboardState {}

final class PersonalExpenseDashboardFetchSuccess
    extends PersonalExpenseDashboardState {
  final List<PersonalExpenseInfoModel> data;
  final bool hasMoreData;

  PersonalExpenseDashboardFetchSuccess({
    required this.data,
    required this.hasMoreData,
  });
}

final class PersonalExpenseDashboardFailure
    extends PersonalExpenseDashboardState {
  final String error;

  PersonalExpenseDashboardFailure({required this.error});
}
