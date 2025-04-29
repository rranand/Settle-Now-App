part of 'personal_expense_bloc.dart';

@immutable
sealed class PersonalMonthlyExpenseEvent {}

final class PersonalMonthlyExpenseFetch extends PersonalMonthlyExpenseEvent {}
