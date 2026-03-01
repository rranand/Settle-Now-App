import 'dart:convert';

import 'package:settlenow/model/notification_model.dart';
import 'package:settlenow/model/room_info_model.dart';
import 'package:settlenow/model/user_model.dart';
import 'package:settlenow/util/custom/pair.dart';
import 'package:settlenow/util/handler/network_call.dart';

class RoomDashboardDataProvider {
  Future<Pair<List<RoomInfoModel>, bool>> fetchData(
    bool isActiveRoom,
    int alreadyHave,
    String authToken,
  ) async {
    try {
      final response = await createAPICall(
        'room${isActiveRoom ? "/open" : "/close"}?alreadyHave=$alreadyHave',
        "get",
        authToken,
        {},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<RoomInfoModel> arr = [];
        bool hasMoreData = data['hasMore'];
        for (int i = 0; i < data['data'].length; i++) {
          arr.add(RoomInfoModel.fromMap(data['data'][i]));
        }
        return Pair(arr, hasMoreData);
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Pair<RoomInfoModel, String>> createRoom(
    String roomName,
    String authToken,
  ) async {
    try {
      final response = await createAPICall('room', 'post', authToken, {
        "roomName": roomName,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        RoomInfoModel newRoomData = RoomInfoModel(
          id: data["data"]["id"],
          roomName: roomName,
          status: "Open",
          createdBy: UserModel.empty(),
          createdOn: DateTime.now(),
          modifiedOn: DateTime.now(),
          users: [],
          roomKey: data["data"]["roomKey"],
          roomLink: data["data"]["roomLink"],
          active: true,
        );
        return Pair(newRoomData, data["data"]["roomMemberID"]);
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<NotificationModel> joinRoom(String roomKey, String authToken) async {
    try {
      final response = await createAPICall(
        'room/join/$roomKey',
        'get',
        authToken,
        {},
      );

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
