part of 'personal_expense_bloc.dart';

@immutable
sealed class PersonalMonthlyExpenseEvent {}

final class PersonalMonthlyExpenseFetch extends PersonalMonthlyExpenseEvent {
  final String year;
  final String month;

  PersonalMonthlyExpenseFetch({required this.year, required this.month});
}

final class PersonalMonthlyExpenseAdd extends PersonalMonthlyExpenseEvent {
  final PersonalExpenseTransactionModel data;

  PersonalMonthlyExpenseAdd({required this.data});
}

final class PersonalMonthlyExpenseUpdate extends PersonalMonthlyExpenseEvent {
  final PersonalExpenseTransactionModel data;

  PersonalMonthlyExpenseUpdate({required this.data});
}

final class PersonalMonthlyExpenseDelete extends PersonalMonthlyExpenseEvent {
  final bool isLoading;
  final String expenseID;

  PersonalMonthlyExpenseDelete({
    required this.isLoading,
    required this.expenseID,
  });
}

final class PersonalMonthlyExpenseReset extends PersonalMonthlyExpenseEvent {}
