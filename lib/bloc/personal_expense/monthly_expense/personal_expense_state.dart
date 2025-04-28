// part of 'personal_expense_bloc.dart';

// @immutable
// sealed class PersonalExpenseState {
//   final bool hasData;

//   const PersonalExpenseState({this.hasData = false});
// }

// final class PersonalExpenseInitial extends PersonalExpenseState {
//   const PersonalExpenseInitial() : super(hasData: false);
// }

// final class PersonalExpenseLoading extends PersonalExpenseState {
//   const PersonalExpenseLoading() : super(hasData: false);
// }

// final class PersonalExpenseFetchSuccess extends PersonalExpenseState {
//   final Map<int, List<PersonalExpenseInfoModel>> data;

//   const PersonalExpenseFetchSuccess(this.data) : super(hasData: true);
// }

// final class PersonalExpenseFailure extends PersonalExpenseState {
//   final String error;

//   const PersonalExpenseFailure(this.error) : super(hasData: false);
// }
