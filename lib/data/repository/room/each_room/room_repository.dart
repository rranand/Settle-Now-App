import 'package:settlenow_v2/data/data_provider/room/each_room/room_data_provider.dart';
import 'package:settlenow_v2/model/new_transaction_model.dart';
import 'package:settlenow_v2/model/room_info_model.dart';
import 'package:settlenow_v2/model/room_settle_model.dart';
import 'package:settlenow_v2/model/room_user_model.dart';
import 'package:settlenow_v2/model/transaction_model.dart';
import 'package:settlenow_v2/model/user_amount_model.dart';
import 'package:settlenow_v2/model/user_model.dart';

class RoomRepository {
  final RoomDataProvider _dataProvider;

  RoomRepository(this._dataProvider);

  Future<RoomInfoModel> fetchRoomInfo(String id, String authToken) async {
    try {
      final RoomInfoModel roomData = await _dataProvider.fetchRoomInfo(
        id,
        authToken,
      );

      return roomData;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TransactionModel>> fetchData(
    String id,
    String authToken,
    List<UserModel> users,
  ) async {
    try {
      List<TransactionModel> data = await _dataProvider.fetchData(
        id,
        authToken,
      );
      Map<String, UserModel> userMap = {};
      for (int i = 0; i < users.length; i++) {
        userMap[users[i].id] = users[i];
      }

      for (int i = 0; i < data.length; i++) {
        data[i].createdBy = UserAmountModel.copyFromUser(
          userMap[data[i].createdBy.id]!,
          data[i].createdBy.amount,
        );
        for (int j = 0; j < data[i].users.length; j++) {
          data[i].users[j] = UserAmountModel.copyFromUser(
            userMap[data[i].users[j].id]!,
            data[i].users[j].amount,
          );
        }
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<RoomUserModel>> fetchUserData(String id, String authToken) async {
    try {
      List<RoomUserModel> data = await _dataProvider.fetchUserData(
        id,
        authToken,
      );
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<RoomSettleModel>> fetchSettleData(
    String id,
    String authToken,
    List<UserModel> users,
  ) async {
    try {
      List<RoomSettleModel> data = await _dataProvider.fetchSettleData(
        id,
        authToken,
      );

      Map<String, UserModel> userMap = {};
      for (int i = 0; i < users.length; i++) {
        userMap[users[i].id] = users[i];
      }

      for (int i = 0; i < data.length; i++) {
        data[i].sender = userMap[data[i].sender.id]!;
        data[i].recevier = userMap[data[i].recevier.id]!;
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<TransactionModel> createExpense(NewTransactionModel data) async {
    try {
      TransactionModel newExpense = await _dataProvider.createExpense(data);
      return newExpense;
    } catch (e) {
      rethrow;
    }
  }

  Future<TransactionModel> updateExpense(NewTransactionModel data) async {
    try {
      TransactionModel updatedExpense = await _dataProvider.updateExpense(data);
      return updatedExpense;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteExpense(String expenseID) async {
    try {
      return _dataProvider.deleteExpense(expenseID);
    } catch (e) {
      rethrow;
    }
  }

  Future<RoomSettleModel> createNewSettleExpense(RoomSettleModel data) async {
    try {
      RoomSettleModel newExpense = await _dataProvider.createNewSettleExpense(
        data,
      );
      return newExpense;
    } catch (e) {
      rethrow;
    }
  }

  Future<RoomSettleModel> updateSettleExpense(RoomSettleModel data) async {
    try {
      RoomSettleModel updatedExpense = await _dataProvider.updateSettleExpense(
        data,
      );
      return updatedExpense;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteSettleExpense(String settleExpenseID) async {
    try {
      return _dataProvider.deleteSettleExpense(settleExpenseID);
    } catch (e) {
      rethrow;
    }
  }
}
