// import 'package:bloc/bloc.dart';
// import 'package:flutter/foundation.dart';
// import 'package:settlenow_v2/data/repository/personal_expense/dashboard/personal_expense_dashboard_repository.dart';
// import 'package:settlenow_v2/model/personal_expense_info_model.dart';

// part 'personal_expense_event.dart';
// part 'personal_expense_state.dart';

// class PersonalExpenseBloc
//     extends Bloc<PersonalExpenseEvent, PersonalExpenseState> {
//   final PersonalExpenseRepository personalExpenseRepository;

//   PersonalExpenseBloc(this.personalExpenseRepository)
//     : super(PersonalExpenseInitial()) {
//     on<PersonalExpenseFetch>(_personalExpenseFetch);
//   }

//   void _personalExpenseFetch(
//     PersonalExpenseFetch event,
//     Emitter<PersonalExpenseState> emit,
//   ) async {
//     emit(PersonalExpenseLoading());
//     try {
//       Map<int, List<PersonalExpenseInfoModel>> data =
//           await personalExpenseRepository.fetchData("niriif@kff.ed");
//       return emit(PersonalExpenseFetchSuccess(data));
//     } catch (e) {
//       return emit(PersonalExpenseFailure(e.toString()));
//     }
//   }
// }
