part of 'personal_expense_bloc.dart';

@immutable
sealed class PersonalExpenseMonthlyExpenseEvent {}

final class PersonalExpenseMonthlyExpenseFetch extends PersonalExpenseMonthlyExpenseEvent {}
