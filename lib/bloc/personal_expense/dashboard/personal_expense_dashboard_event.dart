part of 'personal_expense_dashboard_bloc.dart';

@immutable
sealed class PersonalExpenseDashboardEvent {}

final class PersonalExpenseDashboardFetch
    extends PersonalExpenseDashboardEvent {
  final int alreadyHave;

  PersonalExpenseDashboardFetch({required this.alreadyHave});
}

final class PersonalExpenseDashboardUpdate
    extends PersonalExpenseDashboardEvent {
  final String id;
  final List<PersonalExpenseTransactionModel> data;

  PersonalExpenseDashboardUpdate({required this.id, required this.data});
}

final class PersonalExpenseDashboardOnAdd
    extends PersonalExpenseDashboardEvent {}

final class PersonalExpenseDashboardReset
    extends PersonalExpenseDashboardEvent {}
