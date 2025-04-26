import 'package:settlenow_v2/data/data_provider/room_data_provider.dart';
import 'package:settlenow_v2/model/room_info_model.dart';

class RoomRepository {
  final RoomDataProvider roomDataProvider;

  RoomRepository(this.roomDataProvider);

  Future<List<RoomInfoModel>> fetchData(String email) async {
    try {
      List<RoomInfoModel> data = await roomDataProvider.fetchData(email);
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
