part of 'personal_expense_bloc.dart';

@immutable
sealed class PersonalMonthlyExpenseState {}

final class PersonalMonthlyExpenseInitial extends PersonalMonthlyExpenseState {}

final class PersonalMonthlyExpenseLoading extends PersonalMonthlyExpenseState {}

final class PersonalMonthlyExpenseFetchSuccess
    extends PersonalMonthlyExpenseState {
  final String id;
  final PersonalMonthlyExpensePairTD data;

  PersonalMonthlyExpenseFetchSuccess(this.id, this.data);
}

final class PersonalMonthlyExpenseFailure extends PersonalMonthlyExpenseState {
  final String error;

  PersonalMonthlyExpenseFailure(this.error);
}
