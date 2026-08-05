import 'package:settlenow/data/data_provider/data_provider_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

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

  Future<List<RoomTransactionModel>> fetchData(
    String id,
    List<RoomUserModel> users,
  ) async {
    try {
      List<RoomTransactionModel> data = await _dataProvider.fetchData(id);

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

      for (int i = 0; i < data.length; i++) {
        data[i].sender = UserResolver.instance.resolve(data[i].sender.id);
        data[i].receiver = UserResolver.instance.resolve(data[i].receiver.id);
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

  Future<RoomTransactionModel> createExpense(
    String id,
    RoomTransactionModel data,
  ) async {
    try {
      RoomTransactionModel newExpense = await _dataProvider.createExpense(
        id,
        data,
      );
      return newExpense;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<RoomTransactionModel>> createBulkExpense(
    String id,
    List<RoomTransactionModel> data,
  ) async {
    try {
      List<RoomTransactionModel> newExpense = await _dataProvider
          .createBulkExpense(id, data);
      return newExpense;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateExpense(String id, RoomTransactionModel data) async {
    try {
      await _dataProvider.updateExpense(id, data);
      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteExpense(
    String id,
    String expenseID,
    TransactionType expenseType,
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
    List<BaseUserModel> users,
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
