part of 'personal_expense_bloc.dart';

@immutable
sealed class PersonalMonthlyExpenseState {}

final class PersonalMonthlyExpenseInitial extends PersonalMonthlyExpenseState {}

final class PersonalMonthlyExpenseLoading extends PersonalMonthlyExpenseState {}

final class PersonalMonthlyExpenseFetchSuccess
    extends PersonalMonthlyExpenseState {
  final String id;
  final LinkedHashMap<String, PersonalExpenseTransactionModel> data;
  final List<PersonalExpenseTransactionModel> dataList;

  PersonalMonthlyExpenseFetchSuccess({required this.id, required this.data})
    : dataList = data.values.toList();
}

final class PersonalMonthlyExpenseFailure extends PersonalMonthlyExpenseState {
  final String error;

  PersonalMonthlyExpenseFailure({required this.error});
}
