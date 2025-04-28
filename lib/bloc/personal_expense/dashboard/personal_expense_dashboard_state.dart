part of 'personal_expense_dashboard_bloc.dart';

@immutable
sealed class PersonalExpenseDashboardState {
  final bool hasData;

  const PersonalExpenseDashboardState({this.hasData = false});
}

final class PersonalExpenseDashboardInitial
    extends PersonalExpenseDashboardState {
  const PersonalExpenseDashboardInitial() : super(hasData: false);
}

final class PersonalExpenseDashboardLoading
    extends PersonalExpenseDashboardState {
  const PersonalExpenseDashboardLoading() : super(hasData: false);
}

final class PersonalExpenseDashboardFetchSuccess
    extends PersonalExpenseDashboardState {
  final Map<int, List<PersonalExpenseInfoModel>> data;

  const PersonalExpenseDashboardFetchSuccess(this.data) : super(hasData: true);
}

final class PersonalExpenseDashboardFailure
    extends PersonalExpenseDashboardState {
  final String error;

  const PersonalExpenseDashboardFailure(this.error) : super(hasData: false);
}
