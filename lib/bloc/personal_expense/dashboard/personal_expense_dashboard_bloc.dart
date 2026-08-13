import 'package:bloc/bloc.dart';
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
    on<PersonalExpenseDashboardFetch>(_personalExpenseFetch);
    on<PersonalExpenseDashboardUpdate>(_personalExpenseDashboardUpdate);
    on<PersonalExpenseDashboardReset>(_personalExpenseDashboardReset);
    on<PersonalExpenseDashboardOnAdd>(_personalExpenseDashboardOnAdd);
  }

  void _personalExpenseFetch(
    PersonalExpenseDashboardFetch event,
    Emitter<PersonalExpenseDashboardState> emit,
  ) async {
    List<PersonalExpenseInfoModel> oldData = [];

    if (!event.isFreshFetch && state is PersonalExpenseDashboardFetchSuccess) {
      final allRoomState = state as PersonalExpenseDashboardFetchSuccess;
      if (!allRoomState.hasMoreData) {
        return;
      }
      oldData = allRoomState.data;
    }

    if (state is PersonalExpenseDashboardLoading) {
      return;
    }
    emit(PersonalExpenseDashboardLoading());
    try {
      final data = await repo.fetchData(
        oldData.isEmpty ? DateTime.now() : oldData.last.createdOn,
      );

      return emit(
        PersonalExpenseDashboardFetchSuccess(
          data: [...oldData, ...data.first],
          hasMoreData: data.second,
        ),
      );
    } catch (e) {
      return emit(PersonalExpenseDashboardFailure(error: e.toString()));
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

    final updatedData = [...oldState.data];

    for (int i = 0; i < updatedData.length; i++) {
      if (updatedData[i].id == event.id) {
        updatedData[i] = updatedData[i].copyWith(
          amount: event.totalAmount,
          transactionCount: event.transactionCount,
        );
      }
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

    List<PersonalExpenseInfoModel> oldData = [];
    bool hasMoreDataOld = true;

    if (state is PersonalExpenseDashboardFetchSuccess) {
      final oldState = state as PersonalExpenseDashboardFetchSuccess;

      oldData = oldState.data;
      hasMoreDataOld = oldState.hasMoreData;
    }

    return emit(
      PersonalExpenseDashboardFetchSuccess(
        data: [currentMonthPersonalExpense, ...oldData],
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
