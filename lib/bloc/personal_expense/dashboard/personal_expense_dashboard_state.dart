part of 'personal_expense_dashboard_bloc.dart';

@immutable
sealed class PersonalExpenseDashboardState {}

final class PersonalExpenseDashboardInitial
    extends PersonalExpenseDashboardState {}

final class PersonalExpenseDashboardLoading
    extends PersonalExpenseDashboardState {}

final class PersonalExpenseDashboardFetchSuccess
    extends PersonalExpenseDashboardState {
  final Map<int, List<PersonalExpenseInfoModel>> data;

  PersonalExpenseDashboardFetchSuccess(this.data);
}

final class PersonalExpenseDashboardFailure
    extends PersonalExpenseDashboardState {
  final String error;

  PersonalExpenseDashboardFailure(this.error);
}
