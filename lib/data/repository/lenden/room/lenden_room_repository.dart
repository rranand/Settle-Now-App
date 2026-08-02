import 'package:settlenow/data/data_provider/data_provider_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class LendenRoomRepository {
  final LendenRoomDataProvider _dataProvider;

  LendenRoomRepository(this._dataProvider);

  Future<Tuple<LendenDashboardModel, List<LendenTransactionModel>, bool>>
  fetchData(String id) async {
    try {
      Tuple<LendenDashboardModel, List<LendenTransactionModel>, bool>
      lendenData = await _dataProvider.fetchData(id);
      return lendenData;
    } catch (e) {
      rethrow;
    }
  }

  Future<LendenTransactionModel> create(
    String id,
    LendenTransactionModel expenseData,
  ) async {
    try {
      return _dataProvider.create(id, expenseData);
    } catch (e) {
      rethrow;
    }
  }

  Future<Pair<List<LendenTransactionModel>, bool>> fetchTransaction(
    String id,
    int alreadyHave,
    List<LendenUserModel> users,
  ) async {
    try {
      return _dataProvider.fetchTransaction(id, alreadyHave, users);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> update(String id, LendenTransactionModel expenseData) async {
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

  Future<NotificationModel> inviteUser(
    String roomId,
    String roomName,
    String uid,
  ) async {
    try {
      NotificationModel notificationData = await _dataProvider.inviteUser(
        roomId,
        roomName,
        uid,
      );
      return notificationData;
    } catch (e) {
      rethrow;
    }
  }
}
