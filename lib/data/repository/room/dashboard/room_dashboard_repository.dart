import 'package:settlenow_v2/data/data_provider/room/dashboard/room_dashboard_data_provider.dart';
import 'package:settlenow_v2/model/room_info_model.dart';

class RoomDashboardRepository {
  final RoomDashboardDataProvider _dataProvider;

  RoomDashboardRepository(this._dataProvider);

  Future<List<RoomInfoModel>> fetchData(String email) async {
    try {
      List<RoomInfoModel> data = await _dataProvider.fetchData(email);
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
