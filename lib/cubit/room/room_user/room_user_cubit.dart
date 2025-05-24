import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/data/repository/room/each_room/room_repository.dart';
import 'package:settlenow_v2/model/room_user_model.dart';

part 'room_user_state.dart';

class RoomUserCubit extends Cubit<RoomUserState> {
  final RoomRepository repo;
  RoomUserCubit(this.repo) : super(RoomUserInitial());

  void fetchData(String id) async {
    emit(RoomUserLoading());
    try {
      List<RoomUserModel> data = await repo.fetchUserData("email", id);
      return emit(RoomUserSuccess(data));
    } catch (e) {
      return emit(RoomUserFailure(e.toString()));
    }
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
    return emit(RoomUserSuccess([...usersData].toList()));
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

    return emit(RoomUserSuccess([...usersData].toList()));
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
    return emit(RoomUserSuccess([...usersData].toList()));
  }
}
