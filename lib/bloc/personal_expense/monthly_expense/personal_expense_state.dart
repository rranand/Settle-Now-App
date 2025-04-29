part of 'personal_expense_bloc.dart';

@immutable
sealed class PersonalMonthlyExpenseState {
  final bool hasData;

  const PersonalMonthlyExpenseState({this.hasData = false});
}

final class PersonalMonthlyExpenseInitial extends PersonalMonthlyExpenseState {
  const PersonalMonthlyExpenseInitial() : super(hasData: false);
}

final class PersonalMonthlyExpenseLoading extends PersonalMonthlyExpenseState {
  const PersonalMonthlyExpenseLoading() : super(hasData: false);
}

final class PersonalMonthlyExpenseFetchSuccess
    extends PersonalMonthlyExpenseState {
  final PersonalMonthlyExpensePairTD data;

  const PersonalMonthlyExpenseFetchSuccess(this.data) : super(hasData: true);
}

final class PersonalMonthlyExpenseFailure extends PersonalMonthlyExpenseState {
  final String error;

  const PersonalMonthlyExpenseFailure(this.error) : super(hasData: false);
}
