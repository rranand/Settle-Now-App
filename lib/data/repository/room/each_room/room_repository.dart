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

  Future<Pair<List<RoomTransactionModel>, bool>> fetchData(
    String id,
    DateTime cursor,
  ) async {
    try {
      return await _dataProvider.fetchData(id, cursor);
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

  Future<Pair<List<RoomSettleModel>, bool>> fetchSettleData(
    String id,
    DateTime cursor,
  ) async {
    try {
      Pair<List<RoomSettleModel>, bool> data = await _dataProvider
          .fetchSettleData(id, cursor);

      for (int i = 0; i < data.first.length; i++) {
        data.first[i].sender = UserResolver.instance.resolve(
          data.first[i].sender.id,
        );
        data.first[i].receiver = UserResolver.instance.resolve(
          data.first[i].receiver.id,
        );
      }

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

  Future<void> deleteExpense(
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

  Future<bool> deleteSettleExpense(String id, String expenseID) async {
    try {
      return _dataProvider.deleteSettleExpense(id, expenseID);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> addToPersonalExpense(String id, String expenseID) async {
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

  Future<Pair<List<ActivityModel>, bool>> fetchActivity(
    String id,
    DateTime cursor,
  ) async {
    try {
      return await _dataProvider.fetchActivity(id, cursor);
    } catch (e) {
      rethrow;
    }
  }
}
