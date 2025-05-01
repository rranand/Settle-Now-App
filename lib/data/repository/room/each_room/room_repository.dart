import 'package:settlenow_v2/data/data_provider/room/each_room/room_data_provider.dart';
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
}
