part of 'add_to_personal_expense_bloc.dart';

class AddToPersonalExpenseState {
  Set<String> addingExpenseToPersonalExpense;

  AddToPersonalExpenseState({this.addingExpenseToPersonalExpense = const {}});

  AddToPersonalExpenseState copyWith({
    Set<String>? addingExpenseToPersonalExpense,
  }) {
    return AddToPersonalExpenseState(
      addingExpenseToPersonalExpense:
          addingExpenseToPersonalExpense ?? this.addingExpenseToPersonalExpense,
    );
  }

  @override
  String toString() {
    return 'AddToPersonalExpenseState(TransactionIDs: $addingExpenseToPersonalExpense)';
  }
}
