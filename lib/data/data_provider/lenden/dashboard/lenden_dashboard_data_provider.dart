import 'dart:convert';

import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class LendenDashboardDataProvider {
  Future<Pair<List<LendenDashboardModel>, bool>> fetchData(
    int alreadyHave,
  ) async {
    try {
      final response = await createAPICall(
        'lenden/all?alreadyHave=$alreadyHave',
        "get",
        {},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        bool hasMore = data['has_more'];
        List<LendenDashboardModel> arr = [];
        final allRoomData = data['data'];
        if (allRoomData != null) {
          for (int i = 0; i < allRoomData.length; i++) {
            arr.add(LendenDashboardModel.fromMap(allRoomData[i]));
          }
        }
        return Pair(arr, hasMore);
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<LendenDashboardModel> createRoom(LendenDashboardModel roomData) async {
    try {
      final response = await createAPICall('lenden', "post", {
        "name": roomData.roomName,
      });

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        roomData.id = data["data"]["id"];
        return roomData;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }
}
