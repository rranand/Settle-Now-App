import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';

part 'room_settle_upsert_state.dart';

class RoomSettleUpsertCubit extends Cubit<RoomSettleUpsertState> {
  final RoomRepository _repo;
  final RoomSettleCubit _roomSettleCubit;
  RoomSettleUpsertCubit(this._repo, this._roomSettleCubit)
    : super(RoomSettleUpsertInitial());

  void addNewSettleExpense(String id, RoomSettleModel data) async {
    emit(RoomSettleUpsertLoading());
    try {
      final RoomSettleModel newData = await _repo.createNewSettleExpense(
        id,
        data,
      );
      _roomSettleCubit.addNewSettleExpense(newData);
      return emit(RoomSettleUpsertSuccess(data: newData));
    } catch (e) {
      return emit(RoomSettleUpsertFailure(error: e.toString()));
    }
  }

  void updateSettleExpense(String id, RoomSettleModel data) async {
    emit(RoomSettleUpsertLoading());
    try {
      final updateData = await _repo.updateSettleExpense(id, data);
      final newUpdatedCount = updateData.copyWith(
        activityCount: updateData.activityCount + 1,
      );
      _roomSettleCubit.updateSettleExpense(newUpdatedCount);
      return emit(RoomSettleUpsertSuccess(data: newUpdatedCount));
    } catch (e) {
      return emit(RoomSettleUpsertFailure(error: e.toString()));
    }
  }

  void deleteSettleExpense(String id, String settleExpenseID) async {
    emit(RoomSettleUpsertLoading());
    try {
      await _repo.deleteSettleExpense(id, settleExpenseID);
      _roomSettleCubit.deleteSettleExpense(settleExpenseID);
      return emit(RoomSettleUpsertSuccess(data: RoomSettleModel.empty()));
    } catch (e) {
      return emit(RoomSettleUpsertFailure(error: e.toString()));
    }
  }

  void reset() {
    return emit(RoomSettleUpsertInitial());
  }
}
