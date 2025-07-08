import 'dart:convert';

import 'package:settlenow_v2/model/notification_model.dart';
import 'package:settlenow_v2/util/handler/crypto.dart';
import 'package:settlenow_v2/util/handler/network_call.dart';

class NotificationDataProvider {
  Future<List<NotificationModel>> fetchData(String authToken) async {
    try {
      final response = await createAPICall(
        'notification',
        "get",
        authToken,
        {},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<NotificationModel> arr = [];
        for (int i = 0; i < data['data'].length; i++) {
          arr.add(NotificationModel.fromMap(data['data'][i]));
        }
        return arr;
      } else {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> acceptInvite(String id, String authToken) async {
    try {
      final response = await createAPICall('notification', "put", authToken, {
        id: Crypto.encrypt(id),
      });
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> declineInvite(String id, String authToken) async {
    try {
      final response = await createAPICall(
        'notification',
        "delete",
        authToken,
        {id: Crypto.encrypt(id)},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}
