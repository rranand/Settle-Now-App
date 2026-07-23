import 'package:settlenow/data/data_provider/room/dashboard/room_dashboard_data_provider.dart';
import 'package:settlenow/model/notification_model.dart';
import 'package:settlenow/model/room_info_model.dart';
import 'package:settlenow/model/room_user_model.dart';
import 'package:settlenow/model/user_model.dart';
import 'package:settlenow/util/custom/pair.dart';

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

  Future<RoomInfoModel> createRoom(
    String roomName,
    UserModel user,
    
  ) async {
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

  Future<NotificationModel> joinRoom(String roomKey, ) async {
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
