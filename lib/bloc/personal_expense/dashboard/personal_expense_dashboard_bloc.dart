import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';
part 'personal_expense_dashboard_event.dart';
part 'personal_expense_dashboard_state.dart';

class PersonalExpenseDashboardBloc
    extends Bloc<PersonalExpenseDashboardEvent, PersonalExpenseDashboardState> {
  final PersonalExpenseDashboardRepository repo;

  PersonalExpenseDashboardBloc(this.repo)
    : super(PersonalExpenseDashboardInitial()) {
    on<PersonalExpenseDashboardFetch>(
      _personalExpenseFetch,
      transformer: droppable(),
    );
    on<PersonalExpenseDashboardUpdate>(
      _personalExpenseDashboardUpdate,
      transformer: sequential(),
    );
    on<PersonalExpenseDashboardReset>(
      _personalExpenseDashboardReset,
      transformer: droppable(),
    );
    on<PersonalExpenseDashboardOnAdd>(
      _personalExpenseDashboardOnAdd,
      transformer: droppable(),
    );
  }

  void _personalExpenseFetch(
    PersonalExpenseDashboardFetch event,
    Emitter<PersonalExpenseDashboardState> emit,
  ) async {
    PersonalExpenseDashboardFetchSuccess? oldState;

    if (!event.isFreshFetch && state is PersonalExpenseDashboardFetchSuccess) {
      oldState = state as PersonalExpenseDashboardFetchSuccess;
      if (!oldState.hasMoreData) {
        return;
      }

      emit(oldState.copyWith(isLoadingMore: true, toastMessage: null));
    } else {
      emit(PersonalExpenseDashboardLoading());
    }

    try {
      final data = await repo.fetchData(
        oldState?.dataList.isEmpty ?? true
            ? DateTime.now()
            : oldState!.dataList.last.createdOn,
      );

      final newData =
          LinkedHashMap<String, PersonalExpenseInfoModel>.fromEntries(
            data.first.map((t) => MapEntry(t.id, t)),
          );

      LinkedHashMap<String, PersonalExpenseInfoModel> allRecords =
          LinkedHashMap();
      allRecords.addAll(oldState?.data ?? <String, PersonalExpenseInfoModel>{});
      allRecords.addAll(newData);

      return emit(
        PersonalExpenseDashboardFetchSuccess(
          data: allRecords,
          hasMoreData: data.second,
        ),
      );
    } catch (e) {
      if (oldState == null) {
        return emit(PersonalExpenseDashboardFailure(error: e.toString()));
      } else {
        return emit(
          oldState.copyWith(isLoadingMore: false, toastMessage: e.toString()),
        );
      }
    }
  }

  void _personalExpenseDashboardUpdate(
    PersonalExpenseDashboardUpdate event,
    Emitter<PersonalExpenseDashboardState> emit,
  ) async {
    if (state is! PersonalExpenseDashboardFetchSuccess) {
      return;
    }

    final oldState = state as PersonalExpenseDashboardFetchSuccess;

    LinkedHashMap<String, PersonalExpenseInfoModel> updatedData =
        LinkedHashMap()..addAll(oldState.data);

    if (updatedData.containsKey(event.id)) {
      updatedData[event.id] = updatedData[event.id]!.copyWith(
        amount: event.totalAmount,
        transactionCount: event.transactionCount,
      );
    }

    return emit(
      PersonalExpenseDashboardFetchSuccess(
        data: updatedData,
        hasMoreData: oldState.hasMoreData,
      ),
    );
  }

  void _personalExpenseDashboardOnAdd(
    PersonalExpenseDashboardOnAdd event,
    Emitter<PersonalExpenseDashboardState> emit,
  ) {
    DateTime now = DateTime.now();
    int year = now.year;

    PersonalExpenseInfoModel currentMonthPersonalExpense =
        PersonalExpenseInfoModel(
          id: "",
          amount: 0,
          monthName: CalenderConstant.monthName[now.month - 1],
          transactionCount: 0,
          year: year.toString(),
          createdOn: now,
        );

    LinkedHashMap<String, PersonalExpenseInfoModel> allRecords =
        LinkedHashMap();
    bool hasMoreDataOld = true;

    allRecords.addAll({
      currentMonthPersonalExpense.id: currentMonthPersonalExpense,
    });

    if (state is PersonalExpenseDashboardFetchSuccess) {
      final oldState = state as PersonalExpenseDashboardFetchSuccess;

      allRecords.addAll(oldState.data);
      hasMoreDataOld = oldState.hasMoreData;
    }

    return emit(
      PersonalExpenseDashboardFetchSuccess(
        data: allRecords,
        hasMoreData: hasMoreDataOld,
      ),
    );
  }

  void _personalExpenseDashboardReset(
    PersonalExpenseDashboardReset event,
    Emitter<PersonalExpenseDashboardState> emit,
  ) {
    return emit(PersonalExpenseDashboardInitial());
  }
}
