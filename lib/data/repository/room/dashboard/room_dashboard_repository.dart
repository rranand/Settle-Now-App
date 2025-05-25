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

  Future<RoomInfoModel> createRoom(String roomName) async {
    try {
      RoomInfoModel data = await _dataProvider.createRoom(roomName);
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> joinRoom(String roomKey) async {
    try {
      bool isJoin = await _dataProvider.joinRoom(roomKey);
      return isJoin;
    } catch (e) {
      rethrow;
    }
  }
}
