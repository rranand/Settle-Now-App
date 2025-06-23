import 'package:settlenow_v2/data/data_provider/room/dashboard/room_dashboard_data_provider.dart';
import 'package:settlenow_v2/model/room_info_model.dart';
import 'package:settlenow_v2/util/custom/pair.dart';

class RoomDashboardRepository {
  final RoomDashboardDataProvider _dataProvider;

  RoomDashboardRepository(this._dataProvider);

  Future<Pair<List<RoomInfoModel>, bool>> fetchData(
    bool isActiveRoom,
    int alreadyHave,
    String authToken,
  ) async {
    try {
      Pair<List<RoomInfoModel>, bool> data = await _dataProvider.fetchData(
        isActiveRoom,
        alreadyHave,
        authToken,
      );
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<RoomInfoModel> createRoom(String roomName, String authToken) async {
    try {
      RoomInfoModel data = await _dataProvider.createRoom(roomName, authToken);
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
