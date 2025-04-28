import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/data/repository/personal_expense/monthly_expense/personal_expense_repository.dart';
import 'package:settlenow_v2/util/custom/typedefs.dart';

part 'personal_expense_event.dart';
part 'personal_expense_state.dart';

class PersonalExpenseMonthlyExpenseBloc
    extends
        Bloc<
          PersonalExpenseMonthlyExpenseEvent,
          PersonalExpenseMonthlyExpenseState
        > {
  final PersonalExpenseMonthlyExpenseRepository personalExpenseRepository;

  PersonalExpenseMonthlyExpenseBloc(this.personalExpenseRepository)
    : super(PersonalExpenseMonthlyExpenseInitial()) {
    on<PersonalExpenseMonthlyExpenseFetch>(_personalExpenseFetch);
  }

  void _personalExpenseFetch(
    PersonalExpenseMonthlyExpenseFetch event,
    Emitter<PersonalExpenseMonthlyExpenseState> emit,
  ) async {
    emit(PersonalExpenseMonthlyExpenseLoading());
    try {
      PersonalMonthlyExpenseTD data = await personalExpenseRepository.fetchData(
        "niriif@kff.ed",
      );
      return emit(PersonalExpenseMonthlyExpenseFetchSuccess(data));
    } catch (e) {
      return emit(PersonalExpenseMonthlyExpenseFailure(e.toString()));
    }
  }
}
