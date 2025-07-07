import 'package:settlenow_v2/data/data_provider/lenden/room/lenden_room_data_provider.dart';
import 'package:settlenow_v2/model/lenden_dashboard_model.dart';
import 'package:settlenow_v2/model/lenden_room_model.dart';
import 'package:settlenow_v2/model/new_transaction_model.dart';
import 'package:settlenow_v2/model/notification_model.dart';
import 'package:settlenow_v2/util/custom/pair.dart';

class LendenRoomRepository {
  final LendenRoomDataProvider _dataProvider;

  LendenRoomRepository(this._dataProvider);

  Future<Pair<LendenDashboardModel, List<LendenTransactionModel>>> fetchData(
    String id,
    String authToken,
  ) async {
    try {
      Pair<LendenDashboardModel, List<LendenTransactionModel>> lendenData =
          await _dataProvider.fetchData(id, authToken);
      lendenData.second.sort((a, b) => b.createdOn.compareTo(a.createdOn));
      return _dataProvider.fetchData(id, authToken);
    } catch (e) {
      rethrow;
    }
  }

  Future<LendenTransactionModel> create(
    String id,
    String authToken,
    NewTransactionModel expenseData,
  ) async {
    try {
      return _dataProvider.create(id, authToken, expenseData);
    } catch (e) {
      rethrow;
    }
  }

  Future<LendenTransactionModel> update(
    String id,
    String authToken,
    NewTransactionModel expenseData,
  ) async {
    try {
      return _dataProvider.update(id, authToken, expenseData);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> delete(String id, String authToken, String expenseID) async {
    try {
      return _dataProvider.delete(id, authToken, expenseID);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> closeRoom(String roomID, String authToken) async {
    try {
      return _dataProvider.closeRoom(roomID, authToken);
    } catch (e) {
      rethrow;
    }
  }

  Future<NotificationModel> inviteUser(
    String roomID,
    String uid,
    String authToken,
  ) async {
    try {
      NotificationModel notificationData = await _dataProvider.inviteUser(
        roomID,
        uid,
        authToken,
      );
      return notificationData;
    } catch (e) {
      rethrow;
    }
  }
}
