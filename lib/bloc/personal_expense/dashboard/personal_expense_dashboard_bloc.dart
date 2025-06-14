import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/data/repository/personal_expense/dashboard/personal_expense_dashboard_repository.dart';
import 'package:settlenow_v2/model/personal_expense_info_model.dart';

part 'personal_expense_dashboard_event.dart';
part 'personal_expense_dashboard_state.dart';

class PersonalExpenseDashboardBloc
    extends Bloc<PersonalExpenseDashboardEvent, PersonalExpenseDashboardState> {
  final PersonalExpenseDashboardRepository repo;

  PersonalExpenseDashboardBloc(this.repo)
    : super(PersonalExpenseDashboardInitial()) {
    on<PersonalExpenseDashboardFetch>(_personalExpenseFetch);
  }

  void _personalExpenseFetch(
    PersonalExpenseDashboardFetch event,
    Emitter<PersonalExpenseDashboardState> emit,
  ) async {
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
}
