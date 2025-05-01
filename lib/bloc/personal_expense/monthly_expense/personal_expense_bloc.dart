import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/data/repository/personal_expense/monthly_expense/personal_expense_repository.dart';
import 'package:settlenow_v2/util/custom/typedefs.dart';

part 'personal_expense_event.dart';
part 'personal_expense_state.dart';

class PersonalMonthlyExpenseBloc
    extends Bloc<PersonalMonthlyExpenseEvent, PersonalMonthlyExpenseState> {
  final PersonalMonthlyExpenseRepository repo;

  PersonalMonthlyExpenseBloc(this.repo)
    : super(PersonalMonthlyExpenseInitial()) {
    on<PersonalMonthlyExpenseFetch>(_personalExpenseFetch);
  }

  void _personalExpenseFetch(
    PersonalMonthlyExpenseFetch event,
    Emitter<PersonalMonthlyExpenseState> emit,
  ) async {
    emit(PersonalMonthlyExpenseLoading());
    try {
      PersonalMonthlyExpensePairTD data = await repo.fetchData(
        "niriif@kff.ed",
        event.year,
        event.month,
      );
      return emit(
        PersonalMonthlyExpenseFetchSuccess(
          (event.year + event.month).toLowerCase(),
          data,
        ),
      );
    } catch (e) {
      return emit(PersonalMonthlyExpenseFailure(e.toString()));
    }
  }
}
