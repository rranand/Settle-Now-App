import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
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
    on<PersonalMonthlyExpenseFetch>(
      _personalExpenseFetch,
      transformer: droppable(),
    );
    on<PersonalMonthlyExpenseAdd>(
      _personalMonthlyExpenseAdd,
      transformer: sequential(),
    );
    on<PersonalMonthlyExpenseUpdate>(
      _personalMonthlyExpenseUpdate,
      transformer: sequential(),
    );
    on<PersonalMonthlyExpenseDelete>(
      _personalMonthlyExpenseDelete,
      transformer: sequential(),
    );
    on<PersonalMonthlyExpenseReset>(
      _personalMonthlyExpenseReset,
      transformer: droppable(),
    );
  }

  void _updateDashboardPersonalExpense(
    String id,
    List<PersonalExpenseTransactionModel> data,
  ) {
    dashboardBloc.add(
      PersonalExpenseDashboardUpdate(
        id: id,
        totalAmount: data
            .map((element) => element.amount)
            .fold(0.0, (previousValue, element) => previousValue + element),
        transactionCount: data.length,
      ),
    );
  }

  void _personalExpenseFetch(
    PersonalMonthlyExpenseFetch event,
    Emitter<PersonalMonthlyExpenseState> emit,
  ) async {
    emit(PersonalMonthlyExpenseLoading());

    try {
      String id = (event.year + event.month).toLowerCase();
      final data = await repo.fetchData(event.year, event.month);
      _updateDashboardPersonalExpense(id, data);

      final allRecords =
          LinkedHashMap<String, PersonalExpenseTransactionModel>.fromEntries(
            data.map((t) => MapEntry(t.id, t)),
          );

      return emit(PersonalMonthlyExpenseFetchSuccess(id: id, data: allRecords));
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
    final oldState = state as PersonalMonthlyExpenseFetchSuccess;

    LinkedHashMap<String, PersonalExpenseTransactionModel> allRecords =
        LinkedHashMap();
    allRecords.addAll({event.data.id: event.data});
    allRecords.addAll(oldState.data);

    _updateDashboardPersonalExpense(oldState.id, allRecords.values.toList());

    return emit(
      PersonalMonthlyExpenseFetchSuccess(id: oldState.id, data: allRecords),
    );
  }

  void _personalMonthlyExpenseUpdate(
    PersonalMonthlyExpenseUpdate event,
    Emitter<PersonalMonthlyExpenseState> emit,
  ) async {
    if (state is! PersonalMonthlyExpenseFetchSuccess) {
      return;
    }
    final oldState = state as PersonalMonthlyExpenseFetchSuccess;

    LinkedHashMap<String, PersonalExpenseTransactionModel> allRecords =
        LinkedHashMap();
    allRecords.addAll(oldState.data);
    if (allRecords.containsKey(event.data.id)) {
      allRecords[event.data.id] = event.data;
    }

    _updateDashboardPersonalExpense(oldState.id, allRecords.values.toList());

    return emit(
      PersonalMonthlyExpenseFetchSuccess(id: oldState.id, data: allRecords),
    );
  }

  void _personalMonthlyExpenseDelete(
    PersonalMonthlyExpenseDelete event,
    Emitter<PersonalMonthlyExpenseState> emit,
  ) async {
    if (state is! PersonalMonthlyExpenseFetchSuccess) {
      return;
    }
    final oldState = state as PersonalMonthlyExpenseFetchSuccess;

    LinkedHashMap<String, PersonalExpenseTransactionModel> allRecords =
        LinkedHashMap();
    allRecords.addAll(oldState.data);
    allRecords.remove(event.expenseID);

    _updateDashboardPersonalExpense(oldState.id, allRecords.values.toList());

    return emit(
      PersonalMonthlyExpenseFetchSuccess(id: oldState.id, data: allRecords),
    );
  }

  void _personalMonthlyExpenseReset(
    PersonalMonthlyExpenseReset event,
    Emitter<PersonalMonthlyExpenseState> emit,
  ) {
    return emit(PersonalMonthlyExpenseInitial());
  }
}
