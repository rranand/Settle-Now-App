import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/cubit/room/room_user/room_user_cubit.dart';
import 'package:settlenow_v2/data/repository/room/each_room/room_repository.dart';
import 'package:settlenow_v2/model/room_settle_model.dart';

part 'room_settle_state.dart';

class RoomSettleCubit extends Cubit<RoomSettleState> {
  final RoomRepository repo;
  final RoomUserCubit roomUserCubit;
  RoomSettleCubit(this.repo, this.roomUserCubit) : super(RoomSettleInitial());

  void fetchData(String id) async {
    emit(RoomSettleLoading());
    try {
      List<RoomSettleModel> data = await repo.fetchSettleData("email", id);
      return emit(RoomSettleSuccess(data));
    } catch (e) {
      return emit(RoomSettleFailure(e.toString()));
    }
  }

  void addNewSettleExpense(RoomSettleModel data) {
    final roomSettleSuccessState = state as RoomSettleSuccess;
    List<RoomSettleModel> newArr = [data, ...roomSettleSuccessState.data];
    roomUserCubit.onAddNewSettleExpense(data);
    return emit(RoomSettleSuccess(newArr));
  }
}
