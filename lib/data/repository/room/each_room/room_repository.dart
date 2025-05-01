import 'package:settlenow_v2/data/data_provider/room/each_room/room_data_provider.dart';
import 'package:settlenow_v2/model/room_settle_model.dart';
import 'package:settlenow_v2/model/room_user_model.dart';
import 'package:settlenow_v2/model/transaction_model.dart';

class RoomRepository {
  final RoomDataProvider _dataProvider;

  RoomRepository(this._dataProvider);

  Future<List<TransactionModel>> fetchData(String email, String id) async {
    try {
      List<TransactionModel> data = await _dataProvider.fetchData(email, id);
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<RoomUserModel>> fetchUserData(String email, String id) async {
    try {
      List<RoomUserModel> data = await _dataProvider.fetchUserData(email, id);
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<RoomSettleModel>> fetchSettleData(String email, String id) async {
    try {
      List<RoomSettleModel> data = await _dataProvider.fetchSettleData(
        email,
        id,
      );
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
