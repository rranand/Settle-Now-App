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

    List<RoomSettleModel> oldData = [];

    if (!forceRefresh && state is RoomSettleSuccess) {
      final oldState = state as RoomSettleSuccess;
      if (oldState.id == id) {
        if (!oldState.hasMoreData) {
          return;
        }

        oldData = [...(oldState.data)];
      }
    }

    emit(RoomSettleLoading(id: id));
    try {
      final data = await repo.fetchSettleData(
        id,
        oldData.isEmpty ? DateTime.now() : oldData.last.createdOn,
      );
      return emit(
        RoomSettleSuccess(id: id, data: data.first, hasMoreData: data.second),
      );
    } catch (e) {
      return emit(RoomSettleFailure(error: e.toString()));
    }
  }

  void addNewSettleExpense(RoomSettleModel data) {
    if (state is! RoomSettleSuccess) {
      return;
    }
    final roomSettleSuccessState = state as RoomSettleSuccess;
    List<RoomSettleModel> newArr = [data, ...roomSettleSuccessState.data];
    roomUserCubit.onAddNewSettleExpense(data);
    return emit(
      RoomSettleSuccess(
        id: roomSettleSuccessState.id,
        data: newArr,
        hasMoreData: roomSettleSuccessState.hasMoreData,
      ),
    );
  }

  void updateSettleExpense(RoomSettleModel data) {
    if (state is! RoomSettleSuccess) {
      return;
    }
    final roomSettleSuccessState = state as RoomSettleSuccess;
    List<RoomSettleModel> oldArr = [...roomSettleSuccessState.data];
    RoomSettleModel oldData = RoomSettleModel.empty();

    for (int i = 0; i < oldArr.length; i++) {
      if (oldArr[i].id == data.id) {
        oldData = oldArr[i];
        oldArr[i] = data;
        break;
      }
    }
    roomUserCubit.updateSettleExpense(oldData, data);
    return emit(
      RoomSettleSuccess(
        id: roomSettleSuccessState.id,
        data: oldArr,
        hasMoreData: roomSettleSuccessState.hasMoreData,
      ),
    );
  }

  void deleteSettleExpense(String settleExpenseID) {
    if (state is! RoomSettleSuccess) {
      return;
    }
    final roomSettleSuccessState = state as RoomSettleSuccess;
    List<RoomSettleModel> oldArr = [...roomSettleSuccessState.data];

    int index = -1;
    for (int i = 0; i < oldArr.length; i++) {
      if (oldArr[i].id == settleExpenseID) {
        index = i;
        break;
      }
    }
    if (index != -1) {
      roomUserCubit.deleteSettleExpense(oldArr.removeAt(index));
    }
    return emit(
      RoomSettleSuccess(
        id: roomSettleSuccessState.id,
        data: oldArr,
        hasMoreData: roomSettleSuccessState.hasMoreData,
      ),
    );
  }

  void reset() {
    return emit(RoomSettleInitial());
  }
}
