import 'dart:convert';

import 'package:settlenow_v2/model/lenden_dashboard_model.dart';
import 'package:settlenow_v2/util/handler/crypto.dart';
import 'package:settlenow_v2/util/handler/network_call.dart';

class LendenDashboardDataProvider {
  Future<List<LendenDashboardModel>> fetchData(String authToken) async {
    try {
      final response = await createAPICall('lenden/all', "get", authToken, {});

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<LendenDashboardModel> arr = [];
        for (int i = 0; i < data['data'].length; i++) {
          arr.add(LendenDashboardModel.fromMap(data['data'][i]));
        }
        return arr;
      } else {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<LendenDashboardModel> createRoom(
    LendenDashboardModel roomData,
    String authToken,
  ) async {
    try {
      final response = await createAPICall('lenden', "post", authToken, {
        "name": Crypto.encrypt(roomData.roomName),
      });

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        roomData.id = Crypto.decrypt(data["data"]["id"]);
        return roomData;
      } else {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}
