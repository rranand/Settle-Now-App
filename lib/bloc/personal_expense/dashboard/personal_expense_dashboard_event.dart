part of 'personal_expense_dashboard_bloc.dart';

@immutable
sealed class PersonalExpenseDashboardEvent {}

final class PersonalExpenseDashboardFetch
    extends PersonalExpenseDashboardEvent {}
