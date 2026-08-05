import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';

part 'personal_expense_event.dart';
part 'personal_expense_state.dart';

class PersonalMonthlyExpenseBloc
    extends Bloc<PersonalMonthlyExpenseEvent, PersonalMonthlyExpenseState> {
  final PersonalMonthlyExpenseRepository repo;
  final PersonalExpenseDashboardBloc dashboardBloc;

  PersonalMonthlyExpenseBloc(this.repo, this.dashboardBloc)
    : super(PersonalMonthlyExpenseInitial()) {
    on<PersonalMonthlyExpenseFetch>(_personalExpenseFetch);
    on<PersonalMonthlyExpenseAdd>(_personalMonthlyExpenseAdd);
    on<PersonalMonthlyExpenseUpdate>(_personalMonthlyExpenseUpdate);
    on<PersonalMonthlyExpenseDelete>(_personalMonthlyExpenseDelete);
    on<PersonalMonthlyExpenseReset>(_personalMonthlyExpenseReset);
  }

  void _personalExpenseFetch(
    PersonalMonthlyExpenseFetch event,
    Emitter<PersonalMonthlyExpenseState> emit,
  ) async {
    if (state is PersonalMonthlyExpenseLoading) return;
    emit(PersonalMonthlyExpenseLoading());
    try {
      String id = (event.year + event.month).toLowerCase();
      final data = await repo.fetchData(event.year, event.month);
      dashboardBloc.add(PersonalExpenseDashboardUpdate(id: id, data: data));
      return emit(PersonalMonthlyExpenseFetchSuccess(id: id, data: data));
    } catch (e) {
      return emit(PersonalMonthlyExpenseFailure(error: e.toString()));
    }
  }

  void _personalMonthlyExpenseAdd(
    PersonalMonthlyExpenseAdd event,
    Emitter<PersonalMonthlyExpenseState> emit,
  ) async {
    if (state is! PersonalMonthlyExpenseFetchSuccess) {
      return;
    }
    final oldData = state as PersonalMonthlyExpenseFetchSuccess;
    List<PersonalExpenseTransactionModel> data = [event.data, ...oldData.data];
    dashboardBloc.add(
      PersonalExpenseDashboardUpdate(id: oldData.id, data: data),
    );
    return emit(PersonalMonthlyExpenseFetchSuccess(id: oldData.id, data: data));
  }

  void _personalMonthlyExpenseUpdate(
    PersonalMonthlyExpenseUpdate event,
    Emitter<PersonalMonthlyExpenseState> emit,
  ) async {
    if (state is! PersonalMonthlyExpenseFetchSuccess) {
      return;
    }
    final oldData = state as PersonalMonthlyExpenseFetchSuccess;
    List<PersonalExpenseTransactionModel> data = [...oldData.data];
    for (int i = 0; i < data.length; i++) {
      if (data[i].id == event.data.id) {
        data[i] = event.data;
        break;
      }
    }
    dashboardBloc.add(
      PersonalExpenseDashboardUpdate(id: oldData.id, data: data),
    );
    return emit(PersonalMonthlyExpenseFetchSuccess(id: oldData.id, data: data));
  }

  void _personalMonthlyExpenseDelete(
    PersonalMonthlyExpenseDelete event,
    Emitter<PersonalMonthlyExpenseState> emit,
  ) async {
    if (state is! PersonalMonthlyExpenseFetchSuccess) {
      return;
    }
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
    dashboardBloc.add(
      PersonalExpenseDashboardUpdate(id: oldData.id, data: data),
    );
    return emit(PersonalMonthlyExpenseFetchSuccess(id: oldData.id, data: data));
  }

  void _personalMonthlyExpenseReset(
    PersonalMonthlyExpenseReset event,
    Emitter<PersonalMonthlyExpenseState> emit,
  ) {
    return emit(PersonalMonthlyExpenseInitial());
  }
}
