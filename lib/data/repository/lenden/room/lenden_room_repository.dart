import 'package:settlenow_v2/data/data_provider/lenden/room/lenden_room_data_provider.dart';
import 'package:settlenow_v2/model/lenden_room_model.dart';
import 'package:settlenow_v2/model/new_transaction_model.dart';

class LendenRoomRepository {
  final LendenRoomDataProvider _dataProvider;

  LendenRoomRepository(this._dataProvider);

  Future<List<LendenRoomModel>> fetchData(String email, String id) async {
    try {
      return _dataProvider.fetchData(email, id);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> fetchRoomNameByID(String email, String id) async {
    try {
      return _dataProvider.fetchRoomNameByID(email, id);
    } catch (e) {
      rethrow;
    }
  }

  Future<LendenRoomModel> create(NewTransactionModel data) async {
    try {
      return _dataProvider.create(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<LendenRoomModel> update(NewTransactionModel data) async {
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
