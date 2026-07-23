import 'package:settlenow/data/data_provider/lenden/room/lenden_room_data_provider.dart';
import 'package:settlenow/model/lenden_dashboard_model.dart';
import 'package:settlenow/model/lenden_room_model.dart';
import 'package:settlenow/model/new_transaction_model.dart';
import 'package:settlenow/model/notification_model.dart';
import 'package:settlenow/util/custom/pair.dart';

class LendenRoomRepository {
  final LendenRoomDataProvider _dataProvider;

  LendenRoomRepository(this._dataProvider);

  Future<Pair<LendenDashboardModel, List<LendenTransactionModel>>> fetchData(
    String id,
  ) async {
    try {
      Pair<LendenDashboardModel, List<LendenTransactionModel>> lendenData =
          await _dataProvider.fetchData(id);
      return lendenData;
    } catch (e) {
      rethrow;
    }
  }

  Future<LendenTransactionModel> create(
    String id,

    NewTransactionModel expenseData,
  ) async {
    try {
      return _dataProvider.create(id, expenseData);
    } catch (e) {
      rethrow;
    }
  }

  Future<LendenTransactionModel> update(
    String id,

    NewTransactionModel expenseData,
  ) async {
    try {
      return _dataProvider.update(id, expenseData);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> delete(String id, String expenseID) async {
    try {
      return _dataProvider.delete(id, expenseID);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> closeRoom(String roomID) async {
    try {
      return _dataProvider.closeRoom(roomID);
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

  Future<NotificationModel> inviteUser(String roomID, String uid) async {
    try {
      NotificationModel notificationData = await _dataProvider.inviteUser(
        roomID,
        uid,
      );
      return notificationData;
    } catch (e) {
      rethrow;
    }
  }
}
