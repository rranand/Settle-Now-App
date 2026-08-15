import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

part 'quicksplit_event.dart';
part 'quicksplit_state.dart';

class QuicksplitBloc extends Bloc<QuicksplitEvent, QuicksplitState> {
  final QuicksplitRepository repo;

  QuicksplitBloc(this.repo) : super(QuicksplitInitial()) {
    on<QuicksplitFetch>(_quicksplitFetch, transformer: droppable());
    on<QuicksplitAddNewTransaction>(
      _quicksplitAddNewTransaction,
      transformer: sequential(),
    );
    on<QuicksplitUpdateTransaction>(
      _quicksplitUpdateTransaction,
      transformer: sequential(),
    );
    on<QuicksplitDeleteTransaction>(
      _quicksplitDeleteTransaction,
      transformer: sequential(),
    );
    on<QuicksplitAddToPersonalExpense>(
      _quicksplitAddToPersonalExpense,
      transformer: sequential(),
    );
    on<QuicksplitSettleRequest>(
      _quicksplitSettleRequest,
      transformer: sequential(),
    );
    on<QuicksplitReset>(_quicksplitReset, transformer: droppable());
  }

  void _quicksplitFetch(
    QuicksplitFetch event,
    Emitter<QuicksplitState> emit,
  ) async {
    QuicksplitFetchSuccess? oldState;

    if (!event.isFreshFetch && state is QuicksplitFetchSuccess) {
      oldState = state as QuicksplitFetchSuccess;
      if (!oldState.hasMoreData) {
        return;
      }

      emit(oldState.copyWith(isLoadingMore: true, toastMessage: null));
    } else {
      emit(QuicksplitLoading());
    }

    try {
      Pair<List<QuicksplitTransactionModel>, bool> data = await repo.fetchData(
        oldState == null || oldState.dataList.isEmpty
            ? DateTime.now()
            : oldState.dataList.last.createdOn,
      );

      final newData =
          LinkedHashMap<String, QuicksplitTransactionModel>.fromEntries(
            data.first.map((t) => MapEntry(t.id, t)),
          );

      LinkedHashMap<String, QuicksplitTransactionModel> allRecords =
          LinkedHashMap();
      allRecords.addAll(
        oldState?.data ?? <String, QuicksplitTransactionModel>{},
      );
      allRecords.addAll(newData);

      return emit(
        QuicksplitFetchSuccess(data: allRecords, hasMoreData: data.second),
      );
    } catch (e) {
      if (oldState == null) {
        return emit(QuicksplitFailure(error: e.toString()));
      } else {
        return emit(
          oldState.copyWith(isLoadingMore: false, toastMessage: e.toString()),
        );
      }
    }
  }

  void _quicksplitAddNewTransaction(
    QuicksplitAddNewTransaction event,
    Emitter<QuicksplitState> emit,
  ) async {
    if (state is! QuicksplitFetchSuccess) {
      return;
    }
    final oldState = state as QuicksplitFetchSuccess;

    LinkedHashMap<String, QuicksplitTransactionModel> allRecords =
        LinkedHashMap();
    allRecords.addAll({event.data.id: event.data});
    allRecords.addAll(oldState.data);

    return emit(
      QuicksplitFetchSuccess(
        data: allRecords,
        hasMoreData: oldState.hasMoreData,
      ),
    );
  }

  void _quicksplitUpdateTransaction(
    QuicksplitUpdateTransaction event,
    Emitter<QuicksplitState> emit,
  ) async {
    if (state is! QuicksplitFetchSuccess) {
      return;
    }
    final oldState = state as QuicksplitFetchSuccess;

    LinkedHashMap<String, QuicksplitTransactionModel> allRecords =
        LinkedHashMap();
    allRecords.addAll(oldState.data);

    if (allRecords.containsKey(event.data.id)) {
      final oldData = allRecords[event.data.id]!;

      allRecords[event.data.id] = event.data.copyWith(
        personalExpenseId: oldData.personalExpenseId,
      );
    }

    return emit(
      QuicksplitFetchSuccess(
        data: allRecords,
        hasMoreData: oldState.hasMoreData,
      ),
    );
  }

  void _quicksplitDeleteTransaction(
    QuicksplitDeleteTransaction event,
    Emitter<QuicksplitState> emit,
  ) async {
    if (state is! QuicksplitFetchSuccess) {
      return;
    }
    final oldState = state as QuicksplitFetchSuccess;

    LinkedHashMap<String, QuicksplitTransactionModel> allRecords =
        LinkedHashMap();
    allRecords.addAll(oldState.data);
    allRecords.remove(event.transactionID);

    return emit(
      QuicksplitFetchSuccess(
        data: allRecords,
        hasMoreData: oldState.hasMoreData,
      ),
    );
  }

  void _quicksplitAddToPersonalExpense(
    QuicksplitAddToPersonalExpense event,
    Emitter<QuicksplitState> emit,
  ) async {
    if (state is! QuicksplitFetchSuccess) {
      return;
    }

    final oldState = state as QuicksplitFetchSuccess;

    LinkedHashMap<String, QuicksplitTransactionModel> allRecords =
        LinkedHashMap();
    allRecords.addAll(oldState.data);

    if (allRecords.containsKey(event.transactionID)) {
      final oldData = allRecords[event.transactionID]!;

      allRecords[event.transactionID] = oldData.copyWith(
        personalExpenseId: event.personalExpenseID,
      );
    }

    return emit(
      QuicksplitFetchSuccess(
        data: allRecords,
        hasMoreData: oldState.hasMoreData,
      ),
    );
  }

  void _quicksplitSettleRequest(
    QuicksplitSettleRequest event,
    Emitter<QuicksplitState> emit,
  ) {
    if (state is! QuicksplitFetchSuccess) {
      return;
    }
    final oldState = state as QuicksplitFetchSuccess;
    LinkedHashMap<String, QuicksplitTransactionModel> allRecords =
        LinkedHashMap();
    allRecords.addAll(oldState.data);

    if (allRecords.containsKey(event.transactionID)) {
      final oldData = allRecords[event.transactionID]!;
      List<QuicksplitUserModel> updatedUsers = [...oldData.users];
      int settledUserCount = 0;

      for (int i = 0; i < updatedUsers.length; i++) {
        if (updatedUsers[i].id == event.uid) {
          updatedUsers[i] = updatedUsers[i].copyWith(isSettled: true);
        }
        settledUserCount += updatedUsers[i].isSettled ? 1 : 0;
      }

      allRecords[event.transactionID] = oldData.copyWith(
        users: updatedUsers,
        isClosedAny: true,
        active: settledUserCount != updatedUsers.length,
      );
    }

    return emit(
      QuicksplitFetchSuccess(
        data: allRecords,
        hasMoreData: oldState.hasMoreData,
      ),
    );
  }

  void _quicksplitReset(QuicksplitReset event, Emitter<QuicksplitState> emit) {
    return emit(QuicksplitInitial());
  }
}
