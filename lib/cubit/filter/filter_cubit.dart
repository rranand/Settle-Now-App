import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/model/personal_expense_transaction_model.dart';
import 'package:settlenow_v2/util/enum/enums.dart';

part 'filter_state.dart';

class FilterCubit extends Cubit<FilterState> {
  FilterCubit() : super(FilterState());

  void updateSortBy(SortBy? sortBy) => emit(state.copyWith(sortBy: sortBy));

  void updateSortRule(SortRules? sortRule) =>
      emit(state.copyWith(sortRule: sortRule));

  void updateCategories(Set<int> categories) =>
      emit(state.copyWith(selectedCategories: categories));

  void updateAmountRange(RangeValues? range) =>
      emit(state.copyWith(amountRange: range));

  void updateDateRange(DateTimeRange? range) =>
      emit(state.copyWith(dateRange: range));

  void updateCreatedByUser(Set<String> createdByUsers) =>
      emit(state.copyWith(createdByUsers: createdByUsers));

  void updateSplitType(String splitType) =>
      emit(state.copyWith(splitType: splitType));

  void updateRoom(Set<String> room) => emit(state.copyWith(selectedRoom: room));

  void updateState(FilterState filterState) => emit(filterState);

  void filterPersonalExpenseTransaction(
    String id,
    List<PersonalExpenseTransactionModel> data,
  ) {
    List<PersonalExpenseTransactionModel> filteredData = [];

    for (int i = 0; i < data.length; i++) {}

    return emit(state.copyWith(id: id, data: filteredData));
  }
}
