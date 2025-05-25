import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/cubit/room/room_settle/room_settle_cubit.dart';
import 'package:settlenow_v2/data/repository/room/each_room/room_repository.dart';
import 'package:settlenow_v2/model/room_settle_model.dart';

part 'room_settle_upsert_state.dart';

class RoomSettleUpsertCubit extends Cubit<RoomSettleUpsertState> {
  final RoomRepository repo;
  final RoomSettleCubit roomSettleCubit;
  RoomSettleUpsertCubit(this.repo, this.roomSettleCubit)
    : super(RoomSettleUpsertInitial());

  void addNewSettleExpense(RoomSettleModel data) async {
    emit(RoomSettleUpsertLoading());
    try {
      final RoomSettleModel newData = await repo.createNewSettleExpense(data);
      roomSettleCubit.addNewSettleExpense(newData);
      return emit(RoomSettleUpsertSuccess(newData));
    } catch (e) {
      return emit(RoomSettleUpsertFailure(e.toString()));
    }
  }

  void updateSettleExpense(RoomSettleModel data) async {
    emit(RoomSettleUpsertLoading());
    try {
      final RoomSettleModel updateData = await repo.updateSettleExpense(data);
      roomSettleCubit.updateSettleExpense(updateData);
      return emit(RoomSettleUpsertSuccess(updateData));
    } catch (e) {
      return emit(RoomSettleUpsertFailure(e.toString()));
    }
  }

  void deleteSettleExpense(String settleExpenseID) async {
    emit(RoomSettleUpsertLoading());
    try {
      bool isDeleted = await repo.deleteSettleExpense(settleExpenseID);
      if (isDeleted) {
        roomSettleCubit.deleteSettleExpense(settleExpenseID);
        return emit(RoomSettleUpsertSuccess(RoomSettleModel.empty()));
      } else {
        return emit(RoomSettleUpsertFailure("Something Went Wrong!"));
      }
    } catch (e) {
      return emit(RoomSettleUpsertFailure(e.toString()));
    }
  }
}
