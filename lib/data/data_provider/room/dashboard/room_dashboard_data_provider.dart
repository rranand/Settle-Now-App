import 'dart:convert';

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
        'room${isActiveRoom ? "" : "/close"}?alreadyHave=$alreadyHave',
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

  Future<RoomInfoModel> createRoom(String roomName, String authToken) async {
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
        );
        return newRoomData;
      } else {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> joinRoom(String roomKey) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
