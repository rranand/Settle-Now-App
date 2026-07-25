import 'package:settlenow/data/data_provider/data_provider_core.dart';
import 'package:settlenow/model/model_core.dart';

class RoomRepository {
  final RoomDataProvider _dataProvider;

  RoomRepository(this._dataProvider);

  Future<RoomInfoModel> fetchRoomInfo(String id) async {
    try {
      final RoomInfoModel roomData = await _dataProvider.fetchRoomInfo(id);

      return roomData;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TransactionModel>> fetchData(
    String id,

    List<RoomUserModel> users,
  ) async {
    try {
      List<TransactionModel> data = await _dataProvider.fetchData(id);
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

  Future<void> updateRoom(String id, String newRoomName) async {
    try {
      return _dataProvider.updateRoom(id, newRoomName);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRoom(String id) async {
    try {
      return _dataProvider.deleteRoom(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<RoomSettleModel>> fetchSettleData(
    String id,

    List<RoomUserModel> users,
  ) async {
    try {
      List<RoomSettleModel> data = await _dataProvider.fetchSettleData(id);

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

  Future<void> closeRoomRequest(String id) async {
    try {
      await _dataProvider.closeRoomRequest(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> closeRoom(String id) async {
    try {
      await _dataProvider.closeRoom(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<TransactionModel> createExpense(
    String id,
    NewTransactionModel data,
  ) async {
    try {
      TransactionModel newExpense = await _dataProvider.createExpense(id, data);
      return newExpense;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TransactionModel>> createBulkExpense(
    String id,
    List<NewTransactionModel> data,
  ) async {
    try {
      List<TransactionModel> newExpense = await _dataProvider.createBulkExpense(
        id,
        data,
      );
      return newExpense;
    } catch (e) {
      rethrow;
    }
  }

  Future<TransactionModel> updateExpense(
    String id,
    NewTransactionModel data,
  ) async {
    try {
      TransactionModel updatedExpense = await _dataProvider.updateExpense(
        id,
        data,
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
  ) async {
    try {
      return _dataProvider.deleteExpense(id, expenseID, expenseType);
    } catch (e) {
      rethrow;
    }
  }

  Future<RoomSettleModel> createNewSettleExpense(
    String id,
    RoomSettleModel data,
  ) async {
    try {
      RoomSettleModel newExpense = await _dataProvider.createNewSettleExpense(
        id,
        data,
      );
      return newExpense;
    } catch (e) {
      rethrow;
    }
  }

  Future<RoomSettleModel> updateSettleExpense(
    String id,
    RoomSettleModel data,
  ) async {
    try {
      RoomSettleModel updatedExpense = await _dataProvider.updateSettleExpense(
        id,
        data,
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
  ) async {
    try {
      return _dataProvider.deleteSettleExpense(id, expenseID, sender, receiver);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addToPersonalExpense(String id, String expenseID) async {
    try {
      return _dataProvider.addToPersonalExpense(id, expenseID);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<NotificationModel>> inviteNewMember(
    String id,
    List<UserModel> users,
  ) async {
    try {
      List<NotificationModel> notificationData = await _dataProvider
          .inviteNewMember(id, users);

      return notificationData;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ActivityModel>> fetchActivity(String id) async {
    try {
      List<ActivityModel> activityData = await _dataProvider.fetchActivity(id);

      return activityData;
    } catch (e) {
      rethrow;
    }
  }
}
