import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/model/common_transaction_field.dart';
import 'package:settlenow_v2/util/enum/filter_enums.dart';
import 'package:settlenow_v2/util/enum/transaction_type.dart';

part 'filter_state.dart';

class FilterCubit extends Cubit<FilterState> {
  FilterCubit() : super(FilterState());

  void updateFilterApplied(String id, bool isFilterApplied) {
    if (state.id == id) {
      return emit(state.copyWith(id: id, isFilterApplied: isFilterApplied));
    } else {
      return emit(FilterState(id: id, isFilterApplied: false));
    }
  }

  void updateState(
    FilterState filterState,
    String uid,
    TransactionType transactionType,
  ) {
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
        case TransactionType.lenden:
          {
            filterLendenTransaction(
              filterState.id!,
              uid,
              filterState.data.cast<LendenTransactionModel>(),
            );
          }
        case TransactionType.room:
          {
            filterRoomTransaction(
              filterState.id!,
              uid,
              filterState.data.cast<TransactionModel>(),
            );
          }
        default:
          {}
      }
    }
  }

  List<T> sortTransactions<T extends CommonTransactionField>(List<T> data) {
    bool isMostRecent =
        state.sortRule != null && state.sortRule == SortRules.ascending;
    data.sort((a, b) {
      int result;

      switch (state.sortBy) {
        case SortBy.name:
          result = a.description.compareTo(b.description);
          break;
        case SortBy.amount:
          result = a.amount.compareTo(b.amount);
          break;
        case SortBy.dateCreated:
          result = a.createdOn.compareTo(b.createdOn);
          break;
        default:
          result = 0;
          break;
      }

      return isMostRecent ? result : -result;
    });

    return data;
  }

  void filterLendenTransaction(
    String id,
    String uid,
    List<LendenTransactionModel> data,
  ) {
    List<LendenTransactionModel> filteredData = [];
    for (int i = 0; i < data.length; i++) {
      if (state.lendenType != null && state.lendenType != LendenType.none) {
        final isCreatedByUser = data[i].createdBy.id == uid;
        final isOwe = state.lendenType == LendenType.owe;
        final isGave = state.lendenType == LendenType.gave;
        final amount = data[i].amount;

        final isValid =
            isCreatedByUser
                ? (amount < 0 && isOwe) || (amount >= 0 && isGave)
                : (amount >= 0 && isOwe) || (amount <= 0 && isGave);

        if (!isValid) continue;
      }

      if (state.selectedUsers.isNotEmpty &&
          !state.selectedUsers.contains(data[i].createdBy.id)) {
        continue;
      }
      if (state.amountRange != null &&
          !(state.amountRange!.start <= data[i].amount.abs() &&
              data[i].amount.abs() <= state.amountRange!.end)) {
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

    return emit(state.copyWith(id: id, data: sortTransactions(filteredData)));
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

    return emit(state.copyWith(id: id, data: sortTransactions(filteredData)));
  }

  void filterRoomTransaction(
    String id,
    String uid,
    List<TransactionModel> data,
  ) {
    List<TransactionModel> filteredData = [];

    for (int i = 0; i < data.length; i++) {
      if (state.selectedCategories.isNotEmpty &&
          !state.selectedCategories.contains(
            CategoryParser.indexOfCategory(data[i].category),
          )) {
        continue;
      }

      if (state.selectedUsers.isNotEmpty &&
          !state.selectedUsers.contains(data[i].createdBy.id)) {
        continue;
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

    return emit(state.copyWith(id: id, data: sortTransactions(filteredData)));
  }
}
