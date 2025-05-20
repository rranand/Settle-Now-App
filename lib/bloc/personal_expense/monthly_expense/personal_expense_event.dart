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

  PersonalMonthlyExpenseAdd(this.data);
}

final class PersonalMonthlyExpenseUpdate extends PersonalMonthlyExpenseEvent {
  final PersonalExpenseTransactionModel data;

  PersonalMonthlyExpenseUpdate(this.data);
}

final class PersonalMonthlyExpenseDelete extends PersonalMonthlyExpenseEvent {
  final String expenseID;

  PersonalMonthlyExpenseDelete(this.expenseID);
}
