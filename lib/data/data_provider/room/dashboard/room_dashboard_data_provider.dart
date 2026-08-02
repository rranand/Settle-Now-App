import 'dart:convert';

import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class RoomDashboardDataProvider {
  Future<Pair<List<RoomInfoModel>, bool>> fetchData(
    bool isActiveRoom,
    int alreadyHave,
  ) async {
    try {
      final response = await createAPICall(
        'room${isActiveRoom ? "/open" : "/close"}?alreadyHave=$alreadyHave',
        "get",
        {},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<RoomInfoModel> arr = [];
        bool hasMoreData = data['hasMore'];
        final allRooms = data['data'];

        if (allRooms != null) {
          for (int i = 0; i < allRooms.length; i++) {
            arr.add(RoomInfoModel.fromMap(allRooms[i]));
          }
        }

        return Pair(arr, hasMoreData);
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<RoomInfoModel> createRoom(String roomName) async {
    try {
      final response = await createAPICall('room', 'post', {
        "room_name": roomName,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final roomInfo = data['data'];

        RoomInfoModel newRoomData = RoomInfoModel(
          id: roomInfo["id"],
          roomName: roomName,
          status: RoomStatus.open,
          createdBy: "",
          createdOn: DateTime.now(),
          modifiedOn: DateTime.now(),
          users: [],
          roomKey: roomInfo["room_key"],
          roomLink: roomInfo["room_link"],
          active: true,
        );
        return newRoomData;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<NotificationModel> joinRoom(String roomKey) async {
    try {
      final response = await createAPICall('room/join/$roomKey', 'get', {});

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        NotificationModel notificationData = NotificationModel.fromMap(
          data['data'],
        );
        return notificationData;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }
}
