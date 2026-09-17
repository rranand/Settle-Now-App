import 'package:settlenow/data/data_provider/data_provider_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class RoomDashboardRepository {
  final RoomDashboardDataProvider _dataProvider;

  RoomDashboardRepository(this._dataProvider);

  Future<Pair<List<RoomInfoModel>, bool>> fetchData(
    bool isActiveRoom,
    DateTime cursor,
  ) async {
    try {
      Pair<List<RoomInfoModel>, bool> data = await _dataProvider.fetchData(
        isActiveRoom,
        cursor,
      );
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<RoomInfoModel> createRoom(String roomName, UserModel user) async {
    try {
      Tuple<String, String, String> roomMetadata = await _dataProvider
          .createRoom(roomName);

      final baseUser = UserResolver.instance.getLoggedInUser();
      RoomUserModel roomUserModel = RoomUserModel(
        id: baseUser.id,
        name: baseUser.name,
        profilePic: baseUser.profilePic,
        contribution: 0,
        spent: 0,
        settle: 0,
        active: true,
      );

      RoomInfoModel roomData = RoomInfoModel(
        id: roomMetadata.first,
        name: roomName,
        status: RoomStatus.open,
        createdBy: baseUser.id,
        createdOn: DateTime.now(),
        modifiedOn: DateTime.now(),
        users: [roomUserModel],
        key: roomMetadata.second,
        link: roomMetadata.third,
        active: true,
        memberCount: 1,
      );

      return roomData;
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
