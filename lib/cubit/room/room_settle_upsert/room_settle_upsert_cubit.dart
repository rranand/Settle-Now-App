import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';

part 'room_settle_upsert_state.dart';

class RoomSettleUpsertCubit extends Cubit<RoomSettleUpsertState> {
  final RoomRepository repo;
  final RoomSettleCubit roomSettleCubit;
  RoomSettleUpsertCubit(this.repo, this.roomSettleCubit)
    : super(RoomSettleUpsertInitial());

  void addNewSettleExpense(String id, RoomSettleModel data) async {
    emit(RoomSettleUpsertLoading());
    try {
      final RoomSettleModel newData = await repo.createNewSettleExpense(
        id,
        data,
      );
      roomSettleCubit.addNewSettleExpense(newData);
      return emit(RoomSettleUpsertSuccess(data: newData));
    } catch (e) {
      return emit(RoomSettleUpsertFailure(error: e.toString()));
    }
  }

  void updateSettleExpense(String id, RoomSettleModel data) async {
    emit(RoomSettleUpsertLoading());
    try {
      final updateData = await repo.updateSettleExpense(id, data);
      final newUpdatedCount = updateData.copyWith(
        activityCount: updateData.activityCount + 1,
      );
      roomSettleCubit.updateSettleExpense(newUpdatedCount);
      return emit(RoomSettleUpsertSuccess(data: newUpdatedCount));
    } catch (e) {
      return emit(RoomSettleUpsertFailure(error: e.toString()));
    }
  }

  void deleteSettleExpense(String id, String settleExpenseID) async {
    emit(RoomSettleUpsertLoading());
    try {
      await repo.deleteSettleExpense(id, settleExpenseID);
      roomSettleCubit.deleteSettleExpense(settleExpenseID);
      return emit(RoomSettleUpsertSuccess(data: RoomSettleModel.empty()));
    } catch (e) {
      return emit(RoomSettleUpsertFailure(error: e.toString()));
    }
  }

  void reset() {
    return emit(RoomSettleUpsertInitial());
  }
}
