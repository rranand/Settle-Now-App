import 'package:settlenow/data/data_provider/data_provider_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class RoomDashboardRepository {
  final RoomDashboardDataProvider _dataProvider;

  RoomDashboardRepository(this._dataProvider);

  Future<Pair<List<RoomInfoModel>, bool>> fetchData(
    bool isActiveRoom,
    int alreadyHave,
  ) async {
    try {
      Pair<List<RoomInfoModel>, bool> data = await _dataProvider.fetchData(
        isActiveRoom,
        alreadyHave,
      );
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<RoomInfoModel> createRoom(String roomName, UserModel user) async {
    try {
      Pair<RoomInfoModel, String> roomData = await _dataProvider.createRoom(
        roomName,
      );
      RoomInfoModel data = roomData.first;
      data.createdBy = user;
      data.users = [
        RoomUserModel.fromBasicInfo(
          id: roomData.second,
          user: user,
          active: true,
        ),
      ];
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<NotificationModel> joinRoom(String roomKey) async {
    try {
      NotificationModel notificationData = await _dataProvider.joinRoom(
        roomKey,
      );
      return notificationData;
    } catch (e) {
      rethrow;
    }
  }
}
