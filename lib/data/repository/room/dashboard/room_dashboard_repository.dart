import 'package:settlenow_v2/data/data_provider/room/dashboard/room_dashboard_data_provider.dart';
import 'package:settlenow_v2/model/notification_model.dart';
import 'package:settlenow_v2/model/room_info_model.dart';
import 'package:settlenow_v2/model/room_user_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
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

  Future<RoomInfoModel> createRoom(String roomName, UserModel user) async {
    try {
      Pair<RoomInfoModel, String> roomData = await _dataProvider.createRoom(
        roomName,
        user.authToken,
      );
      RoomInfoModel data = roomData.first;
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

  Future<NotificationModel> joinRoom(String roomKey, String authToken) async {
    try {
      NotificationModel notificationData = await _dataProvider.joinRoom(
        roomKey,
        authToken,
      );
      return notificationData;
    } catch (e) {
      rethrow;
    }
  }
}
