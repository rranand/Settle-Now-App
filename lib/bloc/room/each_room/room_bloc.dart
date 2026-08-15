import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';

part 'room_event.dart';
part 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final RoomRepository repo;
  final RoomUserCubit roomUserCubit;

  RoomBloc(this.repo, this.roomUserCubit) : super(RoomInitial()) {
    on<RoomFetch>(_roomFetch, transformer: droppable());
    on<RoomAddNewTransaction>(_roomAddTransaction, transformer: sequential());
    on<RoomUpdateTransaction>(
      _roomUpdateTransaction,
      transformer: sequential(),
    );
    on<RoomDeleteTransaction>(
      _roomDeleteTransaction,
      transformer: sequential(),
    );
    on<RoomBlocReset>(_roomBlocReset, transformer: droppable());
    on<RoomAddToPersonalExpense>(
      _roomAddToPersonalExpense,
      transformer: sequential(),
    );
  }

  void _roomFetch(RoomFetch event, Emitter<RoomState> emit) async {
    if (state is RoomLoading && (state as RoomLoading).id == event.id) {
      return;
    }

    RoomFetchSuccess? oldState;

    if (!event.isFreshFetch && state is RoomFetchSuccess) {
      oldState = state as RoomFetchSuccess;
      if (oldState.id == event.id) {
        if (!oldState.hasMoreData) {
          return;
        }

        emit(oldState.copyWith(isLoadingMore: true, toastMessage: null));
      } else {
        oldState = null;
      }
    }

    if (oldState == null) {
      emit(RoomLoading(id: event.id));
    }

    try {
      final data = await repo.fetchData(
        event.id,
        oldState?.dataList.isEmpty ?? true
            ? DateTime.now()
            : oldState!.dataList.last.createdOn,
      );

      final newData = LinkedHashMap<String, RoomTransactionModel>.fromEntries(
        data.first.map((t) => MapEntry(t.id, t)),
      );

      LinkedHashMap<String, RoomTransactionModel> allRecords = LinkedHashMap();
      allRecords.addAll(oldState?.data ?? <String, RoomTransactionModel>{});
      allRecords.addAll(newData);

      return emit(
        RoomFetchSuccess(
          id: event.id,
          data: allRecords,
          hasMoreData: data.second,
        ),
      );
    } catch (e) {
      if (oldState == null) {
        return emit(RoomFailure(error: e.toString()));
      } else {
        return emit(
          oldState.copyWith(isLoadingMore: false, toastMessage: e.toString()),
        );
      }
    }
  }

  void _roomAddTransaction(
    RoomAddNewTransaction event,
    Emitter<RoomState> emit,
  ) async {
    if (state is! RoomFetchSuccess) {
      return;
    }

    final oldState = (state as RoomFetchSuccess);
    LinkedHashMap<String, RoomTransactionModel> data = LinkedHashMap();

    for (int i = 0; i < event.data.length; i++) {
      roomUserCubit.onAddNewTransaction(event.data[i]);
      data.addAll({event.data[i].id: event.data[i]});
    }
    data.addAll(oldState.data);

    return emit(
      RoomFetchSuccess(
        id: oldState.id,
        data: data,
        hasMoreData: oldState.hasMoreData,
      ),
    );
  }

  void _roomUpdateTransaction(
    RoomUpdateTransaction event,
    Emitter<RoomState> emit,
  ) async {
    if (state is! RoomFetchSuccess) {
      return;
    }
    final oldState = state as RoomFetchSuccess;

    RoomTransactionModel oldExpense =
        oldState.data[event.data.id] ?? RoomTransactionModel.empty();

    final updated = LinkedHashMap<String, RoomTransactionModel>.from(
      oldState.data,
    )..[event.data.id] = event.data;

    roomUserCubit.onUpdateTransaction(oldExpense, event.data);
    return emit(
      RoomFetchSuccess(
        id: oldState.id,
        data: updated,
        hasMoreData: oldState.hasMoreData,
      ),
    );
  }

  void _roomDeleteTransaction(
    RoomDeleteTransaction event,
    Emitter<RoomState> emit,
  ) async {
    if (state is! RoomFetchSuccess) {
      return;
    }
    final oldState = state as RoomFetchSuccess;

    RoomTransactionModel oldExpense =
        oldState.data[event.expenseID] ?? RoomTransactionModel.empty();

    final updatedData = LinkedHashMap<String, RoomTransactionModel>.from(
      oldState.data,
    )..remove(event.expenseID);

    roomUserCubit.onDeleteTransaction(oldExpense);

    return emit(
      RoomFetchSuccess(
        id: oldState.id,
        data: updatedData,
        hasMoreData: oldState.hasMoreData,
      ),
    );
  }

  void _roomBlocReset(RoomBlocReset event, Emitter<RoomState> emit) {
    return emit(RoomInitial());
  }

  void _roomAddToPersonalExpense(
    RoomAddToPersonalExpense event,
    Emitter<RoomState> emit,
  ) {
    if (state is! RoomFetchSuccess) {
      return;
    }
    final oldState = state as RoomFetchSuccess;
    if (oldState.id != event.id) {
      return;
    }

    LinkedHashMap<String, RoomTransactionModel> updatedData =
        LinkedHashMap<String, RoomTransactionModel>.from(oldState.data);

    if (updatedData.containsKey(event.expenseID)) {
      updatedData[event.expenseID] = updatedData[event.expenseID]!.copyWith(
        personalExpenseId: event.personalExpenseID,
      );
    }

    return emit(
      RoomFetchSuccess(
        id: oldState.id,
        data: updatedData,
        hasMoreData: oldState.hasMoreData,
      ),
    );
  }
}
