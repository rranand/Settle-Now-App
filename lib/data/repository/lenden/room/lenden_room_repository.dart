import 'package:settlenow_v2/data/data_provider/lenden/room/lenden_room_data_provider.dart';
import 'package:settlenow_v2/model/lenden_dashboard_model.dart';
import 'package:settlenow_v2/model/lenden_room_model.dart';
import 'package:settlenow_v2/model/new_transaction_model.dart';
import 'package:settlenow_v2/util/custom/pair.dart';

class LendenRoomRepository {
  final LendenRoomDataProvider _dataProvider;

  LendenRoomRepository(this._dataProvider);

  Future<Pair<LendenDashboardModel, List<LendenTransactionModel>>> fetchData(
    String id,
    String authToken,
  ) async {
    try {
      return _dataProvider.fetchData(id, authToken);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> fetchRoomNameByID(String id, String authToken) async {
    try {
      return _dataProvider.fetchRoomNameByID(id, authToken);
    } catch (e) {
      rethrow;
    }
  }

  Future<LendenTransactionModel> create(NewTransactionModel data) async {
    try {
      return _dataProvider.create(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<LendenTransactionModel> update(NewTransactionModel data) async {
    try {
      return _dataProvider.update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> delete(String expenseID) async {
    try {
      return _dataProvider.delete(expenseID);
    } catch (e) {
      rethrow;
    }
  }
}
