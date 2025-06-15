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

  Future<LendenDashboardModel> createRoom(String roomName) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      LendenDashboardModel data = LendenDashboardModel(
        id: "${DateTime.now()}##$roomName",
        roomName: roomName,
        status: "open",
        createdOn: DateTime.now(),
        amount: 0,
        users: [],
      );
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
