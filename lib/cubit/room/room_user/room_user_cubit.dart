import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/cubit/room/room_info/room_info_cubit.dart';
import 'package:settlenow_v2/data/repository/room/each_room/room_repository.dart';
import 'package:settlenow_v2/model/room_settle_model.dart';
import 'package:settlenow_v2/model/room_user_model.dart';

part 'room_user_state.dart';

class RoomUserCubit extends Cubit<RoomUserState> {
  final RoomRepository repo;
  final RoomInfoCubit _roomInfoCubit;
  RoomUserCubit(this.repo, this._roomInfoCubit) : super(RoomUserInitial());

  void fetchData(
    String id,
    List<RoomUserModel> userArr,
    List<TransactionModel> transArr,
    List<RoomSettleModel> settleArr,
  ) async {
    if (state is RoomUserLoading) return;
    emit(RoomUserLoading());
    try {
      Map<String, double> contributionMap = {};
      Map<String, double> spentMap = {};
      Map<String, double> settleMap = {};

      int n = userArr.length;

      for (int i = 0; i < settleArr.length; i++) {
        RoomSettleModel eachObj = settleArr[i];
        String senderUID = eachObj.sender.id;
        String receiverUID = eachObj.receiver.id;

        settleMap[senderUID] = (settleMap[senderUID] ?? 0) + eachObj.amount;
        settleMap[receiverUID] = (settleMap[receiverUID] ?? 0) - eachObj.amount;
      }

      double totalCommonSplitAmount = 0;

      for (int i = 0; i < transArr.length; i++) {
        TransactionModel eachObj = transArr[i];
        String createdBy = eachObj.createdBy.id;

        contributionMap[createdBy] =
            (contributionMap[createdBy] ?? 0) + eachObj.amount;

        if (eachObj.users.isEmpty) {
          totalCommonSplitAmount += eachObj.amount / n;
        } else {
          spentMap[createdBy] =
              (spentMap[createdBy] ?? 0) + eachObj.createdBy.amount;

          for (int j = 0; j < eachObj.users.length; j++) {
            String userID = eachObj.users[j].id;
            spentMap[userID] =
                (spentMap[userID] ?? 0) + eachObj.users[j].amount;
          }
        }
      }

      List<RoomUserModel> data = [];

      for (int i = 0; i < n; i++) {
        String userID = userArr[i].user.id;
        spentMap[userID] = (spentMap[userID] ?? 0) + totalCommonSplitAmount;

        RoomUserModel eachObj = RoomUserModel(
          id: userArr[i].id,
          active: userArr[i].active,
          user: userArr[i].user,
          contribution: contributionMap[userID] ?? 0,
          spent: spentMap[userID] ?? 0,
          settle: settleMap[userID] ?? 0,
        );

        data.add(eachObj);
      }
      _roomInfoCubit.updateRoomData(id);
      return emit(RoomUserSuccess(id, data));
    } catch (e) {
      return emit(RoomUserFailure(e.toString()));
    }
  }

  void updateCloseStatus(String id, String uid, bool active) async {
    if (state is RoomUserSuccess) {
      final oldState = (state as RoomUserSuccess);

      if (oldState.id == id) {
        List<RoomUserModel> userData = [...oldState.data];
        for (int i = 0; i < userData.length; i++) {
          if (userData[i].user.id == uid) {
            userData[i].active = active;
            break;
          }
        }
        _roomInfoCubit.updateUserData(id, userData);
        return emit(RoomUserSuccess(id, userData));
      }
    }

    return;
  }

  void onAddNewTransaction(TransactionModel data) {
    final roomUserState = state as RoomUserSuccess;
    List<RoomUserModel> usersData = roomUserState.data;

    if (data.createdBy.amount == data.amount) {
      for (int i = 0; i < usersData.length; i++) {
        if (usersData[i].user.id == data.createdBy.id) {
          usersData[i].contribution += data.amount;
          usersData[i].spent += data.amount;
          break;
        }
      }
    } else if (data.users.isEmpty) {
      int n = usersData.length;
      double splitAmount = data.amount / n;

      for (int i = 0; i < usersData.length; i++) {
        usersData[i].spent += splitAmount;
        if (usersData[i].user.id == data.createdBy.id) {
          usersData[i].contribution += data.amount;
        }
      }
    } else {
      Map<String, double> userWithAmount = {};
      userWithAmount[data.createdBy.id] = data.createdBy.amount;
      for (int i = 0; i < data.users.length; i++) {
        userWithAmount[data.users[i].id] = data.users[i].amount;
      }
      for (int i = 0; i < usersData.length; i++) {
        if (userWithAmount.containsKey(usersData[i].user.id)) {
          double splitAmount = userWithAmount[usersData[i].user.id]!;
          if (usersData[i].user.id == data.createdBy.id) {
            usersData[i].contribution += data.amount;
          }
          usersData[i].spent += splitAmount;
        }
      }
    }
    _roomInfoCubit.updateRoomData(roomUserState.id);
    return emit(RoomUserSuccess(roomUserState.id, [...usersData].toList()));
  }

  void onUpdateTransaction(TransactionModel oldExpense, TransactionModel data) {
    final roomUserState = state as RoomUserSuccess;
    List<RoomUserModel> usersData = roomUserState.data;

    // Removing amount of old transaction. May be nature of Split can be changed so, logics are different from removing old amount and adding new amount
    if (oldExpense.createdBy.amount == oldExpense.amount) {
      for (int i = 0; i < usersData.length; i++) {
        if (usersData[i].user.id == oldExpense.createdBy.id) {
          usersData[i].contribution -= oldExpense.amount;
          usersData[i].spent -= oldExpense.amount;
          break;
        }
      }
    } else if (oldExpense.users.isEmpty) {
      int n = usersData.length;
      double splitAmount = oldExpense.amount / n;

      for (int i = 0; i < usersData.length; i++) {
        usersData[i].spent -= splitAmount;
        if (usersData[i].user.id == oldExpense.createdBy.id) {
          usersData[i].contribution -= oldExpense.amount;
        }
      }
    } else {
      Map<String, double> userWithAmount = {};
      userWithAmount[oldExpense.createdBy.id] = oldExpense.createdBy.amount;
      for (int i = 0; i < oldExpense.users.length; i++) {
        userWithAmount[oldExpense.users[i].id] = oldExpense.users[i].amount;
      }
      for (int i = 0; i < usersData.length; i++) {
        if (userWithAmount.containsKey(usersData[i].user.id)) {
          double splitAmount = userWithAmount[usersData[i].user.id]!;
          if (usersData[i].user.id == oldExpense.createdBy.id) {
            usersData[i].contribution -= oldExpense.amount;
          }
          usersData[i].spent -= splitAmount;
        }
      }
    }

    // Adding amount of updated transaction
    if (data.createdBy.amount == data.amount) {
      for (int i = 0; i < usersData.length; i++) {
        if (usersData[i].user.id == data.createdBy.id) {
          usersData[i].contribution += data.amount;
          usersData[i].spent += data.amount;
          break;
        }
      }
    } else if (data.users.isEmpty) {
      int n = usersData.length;
      double splitAmount = data.amount / n;

      for (int i = 0; i < usersData.length; i++) {
        usersData[i].spent += splitAmount;
        if (usersData[i].user.id == data.createdBy.id) {
          usersData[i].contribution += data.amount;
        }
      }
    } else {
      Map<String, double> userWithAmount = {};
      userWithAmount[data.createdBy.id] = data.createdBy.amount;
      for (int i = 0; i < data.users.length; i++) {
        userWithAmount[data.users[i].id] = data.users[i].amount;
      }
      for (int i = 0; i < usersData.length; i++) {
        if (userWithAmount.containsKey(usersData[i].user.id)) {
          double splitAmount = userWithAmount[usersData[i].user.id]!;
          if (usersData[i].user.id == data.createdBy.id) {
            usersData[i].contribution += data.amount;
          }
          usersData[i].spent += splitAmount;
        }
      }
    }
    _roomInfoCubit.updateRoomData(roomUserState.id);
    return emit(RoomUserSuccess(roomUserState.id, [...usersData].toList()));
  }

  void onDeleteTransaction(TransactionModel data) {
    final roomUserState = state as RoomUserSuccess;
    List<RoomUserModel> usersData = roomUserState.data;

    if (data.createdBy.amount == data.amount) {
      for (int i = 0; i < usersData.length; i++) {
        if (usersData[i].user.id == data.createdBy.id) {
          usersData[i].contribution -= data.amount;
          usersData[i].spent -= data.amount;
          break;
        }
      }
    } else if (data.users.isEmpty) {
      int n = usersData.length;
      double splitAmount = data.amount / n;

      for (int i = 0; i < usersData.length; i++) {
        usersData[i].spent -= splitAmount;
        if (usersData[i].user.id == data.createdBy.id) {
          usersData[i].contribution -= data.amount;
        }
      }
    } else {
      Map<String, double> userWithAmount = {};
      userWithAmount[data.createdBy.id] = data.createdBy.amount;
      for (int i = 0; i < data.users.length; i++) {
        userWithAmount[data.users[i].id] = data.users[i].amount;
      }
      for (int i = 0; i < usersData.length; i++) {
        if (userWithAmount.containsKey(usersData[i].user.id)) {
          double splitAmount = userWithAmount[usersData[i].user.id]!;
          if (usersData[i].user.id == data.createdBy.id) {
            usersData[i].contribution -= data.amount;
          }
          usersData[i].spent -= splitAmount;
        }
      }
    }
    _roomInfoCubit.updateRoomData(roomUserState.id);
    return emit(RoomUserSuccess(roomUserState.id, [...usersData].toList()));
  }

  void onAddNewSettleExpense(RoomSettleModel data) {
    final roomUserState = state as RoomUserSuccess;
    List<RoomUserModel> usersData = roomUserState.data;

    for (int i = 0; i < usersData.length; i++) {
      if (data.sender.id == usersData[i].user.id) {
        usersData[i].settle += data.amount;
      } else if (data.receiver.id == usersData[i].user.id) {
        usersData[i].settle -= data.amount;
      }
    }
    _roomInfoCubit.updateRoomData(roomUserState.id);
    return emit(RoomUserSuccess(roomUserState.id, [...usersData].toList()));
  }

  void updateSettleExpense(RoomSettleModel oldData, RoomSettleModel data) {
    final roomUserState = state as RoomUserSuccess;
    List<RoomUserModel> usersData = roomUserState.data;

    for (int i = 0; i < usersData.length; i++) {
      if (oldData.sender.id == usersData[i].user.id) {
        usersData[i].settle -= oldData.amount;
      } else if (oldData.receiver.id == usersData[i].user.id) {
        usersData[i].settle += oldData.amount;
      }

      if (data.sender.id == usersData[i].user.id) {
        usersData[i].settle += data.amount;
      } else if (data.receiver.id == usersData[i].user.id) {
        usersData[i].settle -= data.amount;
      }
    }
    _roomInfoCubit.updateRoomData(roomUserState.id);
    return emit(RoomUserSuccess(roomUserState.id, [...usersData].toList()));
  }

  void deleteSettleExpense(RoomSettleModel data) {
    final roomUserState = state as RoomUserSuccess;
    List<RoomUserModel> usersData = roomUserState.data;

    for (int i = 0; i < usersData.length; i++) {
      if (data.sender.id == usersData[i].user.id) {
        usersData[i].settle -= data.amount;
      } else if (data.receiver.id == usersData[i].user.id) {
        usersData[i].settle += data.amount;
      }
    }
    _roomInfoCubit.updateRoomData(roomUserState.id);
    return emit(RoomUserSuccess(roomUserState.id, [...usersData].toList()));
  }

  void reset() {
    return emit(RoomUserInitial());
  }
}
