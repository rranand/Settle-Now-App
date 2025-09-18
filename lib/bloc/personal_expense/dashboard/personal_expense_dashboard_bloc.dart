import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow/constant/calender_constant.dart';
import 'package:settlenow/data/repository/personal_expense/dashboard/personal_expense_dashboard_repository.dart';
import 'package:settlenow/model/personal_expense_info_model.dart';
import 'package:settlenow/model/personal_expense_transaction_model.dart';
import 'package:settlenow/util/functions/text_function.dart';

part 'personal_expense_dashboard_event.dart';
part 'personal_expense_dashboard_state.dart';

class PersonalExpenseDashboardBloc
    extends Bloc<PersonalExpenseDashboardEvent, PersonalExpenseDashboardState> {
  final PersonalExpenseDashboardRepository repo;

  PersonalExpenseDashboardBloc(this.repo)
    : super(PersonalExpenseDashboardInitial()) {
    on<PersonalExpenseDashboardFetch>(_personalExpenseFetch);
    on<PersonalExpenseDashboardUpdate>(_personalExpenseDashboardUpdate);
    on<PersonalExpenseDashboardReset>(_personalExpenseDashboardReset);
    on<PersonalExpenseDashboardOnAdd>(_personalExpenseDashboardOnAdd);
  }

  void _personalExpenseFetch(
    PersonalExpenseDashboardFetch event,
    Emitter<PersonalExpenseDashboardState> emit,
  ) async {
    if (state is PersonalExpenseDashboardLoading) {
      return;
    }
    emit(PersonalExpenseDashboardLoading());
    try {
      Map<int, List<PersonalExpenseInfoModel>> data = await repo.fetchData(
        event.alreadyHave,
        event.authToken,
      );
      return emit(PersonalExpenseDashboardFetchSuccess(data));
    } catch (e) {
      return emit(PersonalExpenseDashboardFailure(e.toString()));
    }
  }

  void _personalExpenseDashboardUpdate(
    PersonalExpenseDashboardUpdate event,
    Emitter<PersonalExpenseDashboardState> emit,
  ) async {
    if (state is! PersonalExpenseDashboardFetchSuccess) {
      return emit(PersonalExpenseDashboardInitial());
    }
    final oldState = state as PersonalExpenseDashboardFetchSuccess;
    final oldData = oldState.data;

    int year = int.parse(event.id.substring(0, 4));
    String month = capatilizeFirstLetter(event.id.substring(4));

    int index = (oldData[year] ?? []).indexWhere(
      (element) =>
          element.year == year.toString() && element.monthName == month,
    );

    List<PersonalExpenseTransactionModel> data = event.data;
    double totalAmount = 0;

    for (int i = 0; i < data.length; i++) {
      totalAmount += data[i].amount;
    }

    PersonalExpenseInfoModel newExpenseInfo = PersonalExpenseInfoModel(
      id: event.id,
      amount: totalAmount,
      monthName: capatilizeFirstLetter(event.id.substring(4)),
      year: year.toString(),
      transaction:
          data.sublist(0, min(10, data.length)).map((e) => e.amount).toList(),
    );

    Map<int, List<PersonalExpenseInfoModel>> newData = Map.from(oldData);

    if (index != -1) {
      newData[year]![index] = newExpenseInfo;
    } else {
      newData[year] = [...?newData[year], newExpenseInfo];
    }

    return emit(PersonalExpenseDashboardFetchSuccess(newData));
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
          transaction: [],
          year: year.toString(),
        );

    Map<int, List<PersonalExpenseInfoModel>> data = {};
    if (state is PersonalExpenseDashboardFetchSuccess) {
      data = Map.from((state as PersonalExpenseDashboardFetchSuccess).data);
    }

    if (data.containsKey(year)) {
      data[year]!.add(currentMonthPersonalExpense);
    } else {
      data[year] = [currentMonthPersonalExpense];
    }
    return emit(PersonalExpenseDashboardFetchSuccess(data));
  }

  void _personalExpenseDashboardReset(
    PersonalExpenseDashboardReset event,
    Emitter<PersonalExpenseDashboardState> emit,
  ) {
    return emit(PersonalExpenseDashboardInitial());
  }
}
