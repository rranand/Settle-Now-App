import 'dart:convert';

import 'package:settlenow/model/lenden_dashboard_model.dart';
import 'package:settlenow/util/handler/network_call.dart';

class LendenDashboardDataProvider {
  Future<List<LendenDashboardModel>> fetchData() async {
    try {
      final response = await createAPICall('lenden/all', "get", {});

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<LendenDashboardModel> arr = [];
        for (int i = 0; i < data['data'].length; i++) {
          arr.add(LendenDashboardModel.fromMap(data['data'][i]));
        }
        return arr;
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
