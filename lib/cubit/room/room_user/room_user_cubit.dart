import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';

part 'room_user_state.dart';

class RoomUserCubit extends Cubit<RoomUserState> {
  final RoomRepository repo;
  final RoomInfoCubit _roomInfoCubit;
  RoomUserCubit(this.repo, this._roomInfoCubit) : super(RoomUserInitial());

  void fetchData(String id, List<RoomUserModel> userArr) async {
    if (state is RoomUserLoading) return;
    emit(RoomUserLoading());
    try {
      return emit(RoomUserSuccess(id: id, data: userArr));
    } catch (e) {
      return emit(RoomUserFailure(error: e.toString()));
    }
  }

  void updateCloseStatus(String id, String uid, bool active) async {
    if (state is RoomUserSuccess) {
      final oldState = (state as RoomUserSuccess);

      if (oldState.id == id) {
        List<RoomUserModel> userData = [...oldState.data];
        for (int i = 0; i < userData.length; i++) {
          if (userData[i].id == uid) {
            userData[i] = userData[i].copyWith(active: active);
            break;
          }
        }
        _roomInfoCubit.updateUserData(id, userData, forceUpdate: true);
        return emit(RoomUserSuccess(id: id, data: userData));
      }
    }

    return;
  }

  void onAddNewTransaction(RoomTransactionModel data) {
    if (state is! RoomUserSuccess) {
      return;
    }
    final roomUserState = state as RoomUserSuccess;
    List<RoomUserModel> usersData = [...roomUserState.data];

    Map<String, double> userWithAmount = {};
    for (int i = 0; i < data.users.length; i++) {
      userWithAmount[data.users[i].id] = data.users[i].amount;
    }

    for (int i = 0; i < usersData.length; i++) {
      if (userWithAmount.containsKey(usersData[i].id)) {
        double splitAmount = userWithAmount[usersData[i].id]!;
        if (usersData[i].id == data.createdBy) {
          usersData[i] = usersData[i].copyWith(
            contribution: usersData[i].contribution + data.amount,
          );
        }
        usersData[i] = usersData[i].copyWith(
          spent: usersData[i].spent + splitAmount,
        );
      }
    }

    _roomInfoCubit.updateRoomData(roomUserState.id, usersData);
    return emit(RoomUserSuccess(id: roomUserState.id, data: usersData));
  }

  void onUpdateTransaction(
    RoomTransactionModel oldExpense,
    RoomTransactionModel data,
  ) {
    if (state is! RoomUserSuccess) {
      return;
    }
    final roomUserState = state as RoomUserSuccess;
    List<RoomUserModel> usersData = [...roomUserState.data];

    // Removing amount of old transaction. May be nature of Split can be changed so, logics are different from removing old amount and adding new amount
    Map<String, double> userWithAmount = {};

    for (int i = 0; i < oldExpense.users.length; i++) {
      userWithAmount[oldExpense.users[i].id] = oldExpense.users[i].amount;
    }

    for (int i = 0; i < usersData.length; i++) {
      if (userWithAmount.containsKey(usersData[i].id)) {
        double splitAmount = userWithAmount[usersData[i].id]!;
        if (usersData[i].id == oldExpense.createdBy) {
          usersData[i] = usersData[i].copyWith(
            contribution: usersData[i].contribution - oldExpense.amount,
          );
        }
        usersData[i] = usersData[i].copyWith(
          spent: usersData[i].spent - splitAmount,
        );
      }
    }

    // Adding amount of updated transaction
    userWithAmount.clear();

    for (int i = 0; i < data.users.length; i++) {
      userWithAmount[data.users[i].id] = data.users[i].amount;
    }

    for (int i = 0; i < usersData.length; i++) {
      if (userWithAmount.containsKey(usersData[i].id)) {
        double splitAmount = userWithAmount[usersData[i].id]!;
        if (usersData[i].id == data.createdBy) {
          usersData[i] = usersData[i].copyWith(
            contribution: usersData[i].contribution + data.amount,
          );
        }
        usersData[i] = usersData[i].copyWith(
          spent: usersData[i].spent + splitAmount,
        );
      }
    }

    _roomInfoCubit.updateRoomData(roomUserState.id, usersData);
    return emit(RoomUserSuccess(id: roomUserState.id, data: usersData));
  }

  void onDeleteTransaction(RoomTransactionModel data) {
    if (state is! RoomUserSuccess) {
      return;
    }
    final roomUserState = state as RoomUserSuccess;
    List<RoomUserModel> usersData = [...roomUserState.data];

    Map<String, double> userWithAmount = {};
    for (int i = 0; i < data.users.length; i++) {
      userWithAmount[data.users[i].id] = data.users[i].amount;
    }
    for (int i = 0; i < usersData.length; i++) {
      if (userWithAmount.containsKey(usersData[i].id)) {
        double splitAmount = userWithAmount[usersData[i].id]!;
        if (usersData[i].id == data.createdBy) {
          usersData[i] = usersData[i].copyWith(
            contribution: usersData[i].contribution - data.amount,
          );
        }
        usersData[i] = usersData[i].copyWith(
          spent: usersData[i].spent - splitAmount,
        );
      }
    }

    _roomInfoCubit.updateRoomData(roomUserState.id, usersData);
    return emit(RoomUserSuccess(id: roomUserState.id, data: usersData));
  }

  void onAddNewSettleExpense(RoomSettleModel data) {
    if (state is! RoomUserSuccess) {
      return;
    }
    final roomUserState = state as RoomUserSuccess;
    List<RoomUserModel> usersData = [...roomUserState.data];

    for (int i = 0; i < usersData.length; i++) {
      if (data.sender.id == usersData[i].id) {
        usersData[i] = usersData[i].copyWith(
          settle: usersData[i].settle + data.amount,
        );
      } else if (data.receiver.id == usersData[i].id) {
        usersData[i] = usersData[i].copyWith(
          settle: usersData[i].settle - data.amount,
        );
      }
    }
    _roomInfoCubit.updateRoomData(roomUserState.id, usersData);
    return emit(RoomUserSuccess(id: roomUserState.id, data: usersData));
  }

  void updateSettleExpense(RoomSettleModel oldData, RoomSettleModel data) {
    if (state is! RoomUserSuccess) {
      return;
    }
    final roomUserState = state as RoomUserSuccess;
    List<RoomUserModel> usersData = [...roomUserState.data];

    for (int i = 0; i < usersData.length; i++) {
      if (oldData.sender.id == usersData[i].id) {
        usersData[i] = usersData[i].copyWith(
          settle: usersData[i].settle - oldData.amount,
        );
      } else if (oldData.receiver.id == usersData[i].id) {
        usersData[i] = usersData[i].copyWith(
          settle: usersData[i].settle + oldData.amount,
        );
      }

      if (data.sender.id == usersData[i].id) {
        usersData[i] = usersData[i].copyWith(
          settle: usersData[i].settle + data.amount,
        );
      } else if (data.receiver.id == usersData[i].id) {
        usersData[i] = usersData[i].copyWith(
          settle: usersData[i].settle - data.amount,
        );
      }
    }
    _roomInfoCubit.updateRoomData(roomUserState.id, usersData);
    return emit(RoomUserSuccess(id: roomUserState.id, data: usersData));
  }

  void deleteSettleExpense(RoomSettleModel data) {
    if (state is! RoomUserSuccess) {
      return;
    }
    final roomUserState = state as RoomUserSuccess;
    List<RoomUserModel> usersData = [...roomUserState.data];

    for (int i = 0; i < usersData.length; i++) {
      if (data.sender.id == usersData[i].id) {
        usersData[i] = usersData[i].copyWith(
          settle: usersData[i].settle - data.amount,
        );
      } else if (data.receiver.id == usersData[i].id) {
        usersData[i] = usersData[i].copyWith(
          settle: usersData[i].settle + data.amount,
        );
      }
    }
    _roomInfoCubit.updateRoomData(roomUserState.id, usersData);
    return emit(RoomUserSuccess(id: roomUserState.id, data: usersData));
  }

  void reset() {
    return emit(RoomUserInitial());
  }
}
