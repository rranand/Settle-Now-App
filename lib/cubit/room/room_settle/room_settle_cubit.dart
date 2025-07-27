import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/cubit/room/room_user/room_user_cubit.dart';
import 'package:settlenow_v2/data/repository/room/each_room/room_repository.dart';
import 'package:settlenow_v2/model/room_settle_model.dart';
import 'package:settlenow_v2/model/room_user_model.dart';

part 'room_settle_state.dart';

class RoomSettleCubit extends Cubit<RoomSettleState> {
  final RoomRepository repo;
  final RoomUserCubit roomUserCubit;
  RoomSettleCubit(this.repo, this.roomUserCubit) : super(RoomSettleInitial());

  void fetchData(String id, String authToken, List<RoomUserModel> users) async {
    if (state is RoomSettleLoading && (state as RoomSettleLoading).id == id) {
      return;
    }
    emit(RoomSettleLoading(id));
    try {
      List<RoomSettleModel> data = await repo.fetchSettleData(
        id,
        authToken,
        users,
      );
      return emit(RoomSettleSuccess(id, data));
    } catch (e) {
      return emit(RoomSettleFailure(e.toString()));
    }
  }

  void addNewSettleExpense(RoomSettleModel data) {
    if (state is! RoomSettleSuccess) {
      return;
    }
    final roomSettleSuccessState = state as RoomSettleSuccess;
    List<RoomSettleModel> newArr = [data, ...roomSettleSuccessState.data];
    roomUserCubit.onAddNewSettleExpense(data);
    return emit(RoomSettleSuccess(roomSettleSuccessState.id, newArr));
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
    return emit(RoomSettleSuccess(roomSettleSuccessState.id, oldArr));
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
    return emit(RoomSettleSuccess(roomSettleSuccessState.id, oldArr));
  }

  void reset() {
    return emit(RoomSettleInitial());
  }
}
