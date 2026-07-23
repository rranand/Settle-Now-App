import 'dart:convert';

import 'package:settlenow/model/notification_model.dart';
import 'package:settlenow/util/handler/network_call.dart';

class NotificationDataProvider {
  Future<List<NotificationModel>> fetchData() async {
    try {
      final response = await createAPICall('notification', "get", {});
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<NotificationModel> arr = [];
        for (int i = 0; i < data['data'].length; i++) {
          arr.add(NotificationModel.fromMap(data['data'][i]));
        }
        return arr;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> acceptInvite(String id) async {
    try {
      final response = await createAPICall('notification', "put", {"id": id});
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return true;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> declineInvite(String id) async {
    try {
      final response = await createAPICall('notification', "delete", {
        "id": id,
      });
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return true;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }
}
