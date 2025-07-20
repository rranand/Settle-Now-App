import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/model/personal_expense_transaction_model.dart';
import 'package:settlenow_v2/util/custom/category_parser.dart';
import 'package:settlenow_v2/util/enum/enums.dart';
import 'package:settlenow_v2/util/enum/transaction_type.dart';

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

  void updateState(FilterState filterState, TransactionType transactionType) {
    emit(filterState);
    if (filterState.data.isNotEmpty) {
      switch (transactionType) {
        case TransactionType.personal:
          {
            filterPersonalExpenseTransaction(
              filterState.id!,
              filterState.data.cast<PersonalExpenseTransactionModel>(),
            );
          }
        default:
          {}
      }
    }
  }

  void filterPersonalExpenseTransaction(
    String id,
    List<PersonalExpenseTransactionModel> data,
  ) {
    List<PersonalExpenseTransactionModel> filteredData = [];

    for (int i = 0; i < data.length; i++) {
      if (state.selectedCategories.isNotEmpty &&
          !state.selectedCategories.contains(
            CategoryParser.indexOfCategory(data[i].category),
          )) {
        continue;
      }
      if (data[i].roomData.hasData && state.selectedRoom.isNotEmpty) {
        String id =
            "${data[i].roomData.roomName}###${data[i].roomData.transactionType == "Quicksplit" ? "" : "Room"}";
        if (!state.selectedRoom.contains(id)) {
          continue;
        }
      }
      if (state.amountRange != null &&
          !(state.amountRange!.start <= data[i].amount &&
              data[i].amount <= state.amountRange!.end)) {
        continue;
      }
      if (state.dateRange != null &&
          !(state.dateRange!.start.millisecondsSinceEpoch <=
                  data[i].createdOn.millisecondsSinceEpoch &&
              data[i].createdOn.millisecondsSinceEpoch <=
                  state.dateRange!.end.millisecondsSinceEpoch)) {
        continue;
      }

      filteredData.add(data[i]);
    }

    return emit(state.copyWith(id: id, data: filteredData));
  }
}
