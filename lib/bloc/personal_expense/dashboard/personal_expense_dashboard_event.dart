part of 'personal_expense_dashboard_bloc.dart';

@immutable
sealed class PersonalExpenseDashboardEvent {}

final class PersonalExpenseDashboardFetch
    extends PersonalExpenseDashboardEvent {
  final String authToken;
  final int alreadyHave;

  PersonalExpenseDashboardFetch({
    required this.authToken,
    required this.alreadyHave,
  });
}
