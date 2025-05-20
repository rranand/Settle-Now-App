import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/data/repository/personal_expense/monthly_expense/personal_expense_repository.dart';
import 'package:settlenow_v2/model/personal_expense_transaction_model.dart';

part 'personal_expense_event.dart';
part 'personal_expense_state.dart';

class PersonalMonthlyExpenseBloc
    extends Bloc<PersonalMonthlyExpenseEvent, PersonalMonthlyExpenseState> {
  final PersonalMonthlyExpenseRepository repo;

  PersonalMonthlyExpenseBloc(this.repo)
    : super(PersonalMonthlyExpenseInitial()) {
    on<PersonalMonthlyExpenseFetch>(_personalExpenseFetch);
    on<PersonalMonthlyExpenseAdd>(_personalMonthlyExpenseAdd);
    on<PersonalMonthlyExpenseUpdate>(_personalMonthlyExpenseUpdate);
    on<PersonalMonthlyExpenseDelete>(_personalMonthlyExpenseDelete);
  }

  void _personalExpenseFetch(
    PersonalMonthlyExpenseFetch event,
    Emitter<PersonalMonthlyExpenseState> emit,
  ) async {
    emit(PersonalMonthlyExpenseLoading());
    try {
      List<PersonalExpenseTransactionModel> data = await repo.fetchData(
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

  void _personalMonthlyExpenseAdd(
    PersonalMonthlyExpenseAdd event,
    Emitter<PersonalMonthlyExpenseState> emit,
  ) async {
    final oldData = state as PersonalMonthlyExpenseFetchSuccess;
    List<PersonalExpenseTransactionModel> data = [event.data, ...oldData.data];
    return emit(PersonalMonthlyExpenseFetchSuccess(oldData.id, data));
  }

  void _personalMonthlyExpenseUpdate(
    PersonalMonthlyExpenseUpdate event,
    Emitter<PersonalMonthlyExpenseState> emit,
  ) async {
    final oldData = state as PersonalMonthlyExpenseFetchSuccess;
    List<PersonalExpenseTransactionModel> data = [...oldData.data];
    for (int i = 0; i < data.length; i++) {
      if (data[i].id == event.data.id) {
        data[i] = event.data;
        break;
      }
    }
    return emit(PersonalMonthlyExpenseFetchSuccess(oldData.id, data));
  }

  void _personalMonthlyExpenseDelete(
    PersonalMonthlyExpenseDelete event,
    Emitter<PersonalMonthlyExpenseState> emit,
  ) async {
    final oldData = state as PersonalMonthlyExpenseFetchSuccess;
    List<PersonalExpenseTransactionModel> data = [...oldData.data];
    if (event.isLoading) {
      for (int i = 0; i < data.length; i++) {
        if (data[i].id == event.expenseID) {
          data[i].hasData = false;
          break;
        }
      }
    } else {
      data.removeWhere((element) => element.id == event.expenseID);
    }
    return emit(PersonalMonthlyExpenseFetchSuccess(oldData.id, data));
  }
}
