part of 'personal_expense_bloc.dart';

@immutable
sealed class PersonalExpenseEvent {}

final class PersonalExpenseFetch extends PersonalExpenseEvent {}
