part of 'personal_expense_bloc.dart';

@immutable
sealed class PersonalMonthlyExpenseEvent {}

final class PersonalMonthlyExpenseFetch extends PersonalMonthlyExpenseEvent {
  final String year;
  final String month;
  PersonalMonthlyExpenseFetch({required this.year, required this.month});
}
