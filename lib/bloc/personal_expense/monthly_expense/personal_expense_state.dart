part of 'personal_expense_bloc.dart';

@immutable
sealed class PersonalExpenseMonthlyExpenseState {
  final bool hasData;

  const PersonalExpenseMonthlyExpenseState({this.hasData = false});
}

final class PersonalExpenseMonthlyExpenseInitial
    extends PersonalExpenseMonthlyExpenseState {
  const PersonalExpenseMonthlyExpenseInitial() : super(hasData: false);
}

final class PersonalExpenseMonthlyExpenseLoading
    extends PersonalExpenseMonthlyExpenseState {
  const PersonalExpenseMonthlyExpenseLoading() : super(hasData: false);
}

final class PersonalExpenseMonthlyExpenseFetchSuccess
    extends PersonalExpenseMonthlyExpenseState {
  final PersonalMonthlyExpenseTD data;

  const PersonalExpenseMonthlyExpenseFetchSuccess(this.data)
    : super(hasData: true);
}

final class PersonalExpenseMonthlyExpenseFailure
    extends PersonalExpenseMonthlyExpenseState {
  final String error;

  const PersonalExpenseMonthlyExpenseFailure(this.error)
    : super(hasData: false);
}
