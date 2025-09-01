import 'package:settlenow_v2/data/data_provider/room/each_room/room_data_provider.dart';
import 'package:settlenow_v2/model/new_transaction_model.dart';
import 'package:settlenow_v2/model/notification_model.dart';
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
    List<RoomUserModel> users,
  ) async {
    try {
      List<TransactionModel> data = await _dataProvider.fetchData(
        id,
        authToken,
      );
      Map<String, UserModel> userMap = {};
      for (int i = 0; i < users.length; i++) {
        userMap[users[i].user.id] = users[i].user;
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

  Future<void> updateRoom(
    String id,
    String authToken,
    String newRoomName,
  ) async {
    try {
      return _dataProvider.updateRoom(id, authToken, newRoomName);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRoom(String id, String authToken) async {
    try {
      return _dataProvider.deleteRoom(id, authToken);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<RoomSettleModel>> fetchSettleData(
    String id,
    String authToken,
    List<RoomUserModel> users,
  ) async {
    try {
      List<RoomSettleModel> data = await _dataProvider.fetchSettleData(
        id,
        authToken,
      );

      Map<String, UserModel> userMap = {};
      for (int i = 0; i < users.length; i++) {
        userMap[users[i].user.id] = users[i].user;
      }

      for (int i = 0; i < data.length; i++) {
        data[i].sender = userMap[data[i].sender.id]!;
        data[i].receiver = userMap[data[i].receiver.id]!;
      }
      data.sort((a, b) => b.createdOn.compareTo(a.createdOn));
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> closeRoomRequest(String id, String authToken) async {
    try {
      await _dataProvider.closeRoomRequest(id, authToken);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> closeRoom(String id, String authToken) async {
    try {
      await _dataProvider.closeRoom(id, authToken);
    } catch (e) {
      rethrow;
    }
  }

  Future<TransactionModel> createExpense(
    String id,
    NewTransactionModel data,
    String authToken,
  ) async {
    try {
      TransactionModel newExpense = await _dataProvider.createExpense(
        id,
        data,
        authToken,
      );
      return newExpense;
    } catch (e) {
      rethrow;
    }
  }

  Future<TransactionModel> updateExpense(
    String id,
    NewTransactionModel data,
    String expenseType,
    String authToken,
  ) async {
    try {
      TransactionModel updatedExpense = await _dataProvider.updateExpense(
        id,
        data,
        expenseType,
        authToken,
      );
      return updatedExpense;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteExpense(
    String id,
    String expenseID,
    String expenseType,
    String authToken,
  ) async {
    try {
      return _dataProvider.deleteExpense(id, expenseID, expenseType, authToken);
    } catch (e) {
      rethrow;
    }
  }

  Future<RoomSettleModel> createNewSettleExpense(
    String id,
    RoomSettleModel data,
    String authToken,
  ) async {
    try {
      RoomSettleModel newExpense = await _dataProvider.createNewSettleExpense(
        id,
        data,
        authToken,
      );
      return newExpense;
    } catch (e) {
      rethrow;
    }
  }

  Future<RoomSettleModel> updateSettleExpense(
    String id,
    RoomSettleModel data,
    String authToken,
  ) async {
    try {
      RoomSettleModel updatedExpense = await _dataProvider.updateSettleExpense(
        id,
        data,
        authToken,
      );
      return updatedExpense;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteSettleExpense(
    String id,
    String expenseID,
    String sender,
    String receiver,
    String authToken,
  ) async {
    try {
      return _dataProvider.deleteSettleExpense(
        id,
        expenseID,
        sender,
        receiver,
        authToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addToPersonalExpense(
    String id,
    String expenseID,
    String splitType,
    String authToken,
  ) async {
    try {
      return _dataProvider.addToPersonalExpense(
        id,
        expenseID,
        splitType,
        authToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<NotificationModel>> inviteNewMember(
    String id,
    List<UserModel> users,
    String authToken,
  ) async {
    try {
      List<NotificationModel> notificationData = await _dataProvider
          .inviteNewMember(id, users, authToken);

      return notificationData;
    } catch (e) {
      rethrow;
    }
  }
}
