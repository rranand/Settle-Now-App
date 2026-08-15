import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';

part 'room_settle_state.dart';

class RoomSettleCubit extends Cubit<RoomSettleState> {
  final RoomRepository repo;
  final RoomUserCubit roomUserCubit;
  RoomSettleCubit(this.repo, this.roomUserCubit) : super(RoomSettleInitial());

  void fetchData(String id, bool forceRefresh) async {
    if (state is RoomSettleLoading && (state as RoomSettleLoading).id == id) {
      return;
    }

    RoomSettleSuccess? oldState;

    if (!forceRefresh && state is RoomSettleSuccess) {
      oldState = state as RoomSettleSuccess;
      if (oldState.id == id) {
        if (!oldState.hasMoreData) {
          return;
        }

        emit(oldState.copyWith(isLoadingMore: true, toastMessage: null));
      } else {
        oldState = null;
      }
    }

    if (oldState == null) {
      emit(RoomSettleLoading(id: id));
    }

    try {
      final data = await repo.fetchSettleData(
        id,
        oldState == null || oldState.dataList.isEmpty
            ? DateTime.now()
            : oldState.dataList.last.createdOn,
      );

      final newData = LinkedHashMap<String, RoomSettleModel>.fromEntries(
        data.first.map((t) => MapEntry(t.id, t)),
      );
      LinkedHashMap<String, RoomSettleModel> allRecords = LinkedHashMap();
      allRecords.addAll(oldState?.data ?? <String, RoomSettleModel>{});
      allRecords.addAll(newData);

      return emit(
        RoomSettleSuccess(id: id, data: allRecords, hasMoreData: data.second),
      );
    } catch (e) {
      if (oldState == null) {
        return emit(RoomSettleFailure(error: e.toString()));
      } else {
        return emit(
          oldState.copyWith(isLoadingMore: false, toastMessage: e.toString()),
        );
      }
    }
  }

  void addNewSettleExpense(RoomSettleModel data) {
    if (state is! RoomSettleSuccess) {
      return;
    }
    final oldState = state as RoomSettleSuccess;

    LinkedHashMap<String, RoomSettleModel> allRecords = LinkedHashMap();
    allRecords.addAll({data.id: data});
    allRecords.addAll(oldState.data);

    roomUserCubit.onAddNewSettleExpense(data);

    return emit(
      RoomSettleSuccess(
        id: oldState.id,
        data: allRecords,
        hasMoreData: oldState.hasMoreData,
      ),
    );
  }

  void updateSettleExpense(RoomSettleModel data) {
    if (state is! RoomSettleSuccess) {
      return;
    }
    final oldState = state as RoomSettleSuccess;

    RoomSettleModel oldData = oldState.data[data.id] ?? RoomSettleModel.empty();

    final updatedData = LinkedHashMap<String, RoomSettleModel>.from(
      oldState.data,
    )..[data.id] = data;

    roomUserCubit.updateSettleExpense(oldData, data);

    return emit(
      RoomSettleSuccess(
        id: oldState.id,
        data: updatedData,
        hasMoreData: oldState.hasMoreData,
      ),
    );
  }

  void deleteSettleExpense(String settleExpenseID) {
    if (state is! RoomSettleSuccess) {
      return;
    }
    final oldState = state as RoomSettleSuccess;
    RoomSettleModel oldData =
        oldState.data[settleExpenseID] ?? RoomSettleModel.empty();

    final updatedData = LinkedHashMap<String, RoomSettleModel>.from(
      oldState.data,
    )..remove(settleExpenseID);

    roomUserCubit.deleteSettleExpense(oldData);

    return emit(
      RoomSettleSuccess(
        id: oldState.id,
        data: updatedData,
        hasMoreData: oldState.hasMoreData,
      ),
    );
  }

  void reset() {
    return emit(RoomSettleInitial());
  }
}
