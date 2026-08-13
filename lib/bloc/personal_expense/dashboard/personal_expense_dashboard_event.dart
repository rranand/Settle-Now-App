part of 'personal_expense_dashboard_bloc.dart';

@immutable
sealed class PersonalExpenseDashboardEvent {}

final class PersonalExpenseDashboardFetch
    extends PersonalExpenseDashboardEvent {
  final bool isFreshFetch;

  PersonalExpenseDashboardFetch({required this.isFreshFetch});
}

final class PersonalExpenseDashboardUpdate
    extends PersonalExpenseDashboardEvent {
  final String id;
  final double totalAmount;
  final int transactionCount;

  PersonalExpenseDashboardUpdate({
    required this.id,
    required this.totalAmount,
    required this.transactionCount,
  });
}

final class PersonalExpenseDashboardOnAdd
    extends PersonalExpenseDashboardEvent {}

final class PersonalExpenseDashboardReset
    extends PersonalExpenseDashboardEvent {}
