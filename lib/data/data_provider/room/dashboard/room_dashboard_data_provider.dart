import 'dart:convert';

import 'package:settlenow_v2/model/notification_model.dart';
import 'package:settlenow_v2/model/room_info_model.dart';
import 'package:settlenow_v2/util/custom/pair.dart';
import 'package:settlenow_v2/util/handler/crypto.dart';
import 'package:settlenow_v2/util/handler/network_call.dart';

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
        bool hasMoreData = Crypto.decrypt(data['hasMore']) == 'true';
        for (int i = 0; i < data['data'].length; i++) {
          arr.add(RoomInfoModel.fromMap(data['data'][i]));
        }
        return Pair(arr, hasMoreData);
      } else {
        throw Crypto.decrypt(data['message']);
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
        "roomName": Crypto.encrypt(roomName),
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        RoomInfoModel newRoomData = RoomInfoModel(
          id: Crypto.decrypt(data["data"]["id"]),
          roomName: roomName,
          status: "Open",
          createdOn: DateTime.now(),
          users: [],
          roomKey: Crypto.decrypt(data["data"]["roomKey"]),
          roomLink: Crypto.decrypt(data["data"]["roomLink"]),
          active: true,
        );
        return Pair(newRoomData, Crypto.decrypt(data["data"]["roomMemberID"]));
      } else {
        throw Crypto.decrypt(data['message']);
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
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}
