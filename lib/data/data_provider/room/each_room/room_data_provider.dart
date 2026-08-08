library;

import 'dart:convert';

import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

part 'room_activity_data_provider.dart';
part 'room_transaction_data_provider.dart';
part 'room_settle_expense_data_provider.dart';

class RoomDataProvider {
  Future<RoomInfoModel> fetchRoomInfo(String id) async {
    try {
      final response = await createAPICall('room/$id/info', "get", {});

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        RoomInfoModel roomData = RoomInfoModel.fromMap(data['data']);
        return roomData;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> closeRoomRequest(String id) async {
    try {
      final response = await createAPICall('room/$id/close/request', "get", {});

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> closeRoom(String id) async {
    try {
      final response = await createAPICall('room/$id/close', "get", {});

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRoom(String id, String newRoomName) async {
    try {
      final response = await createAPICall('room/$id', "patch", {
        "name": newRoomName,
      });

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRoom(String id) async {
    try {
      final response = await createAPICall('room/$id', "delete", {});

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<NotificationModel>> inviteNewMember(
    String id,
    List<BaseUserModel> users,
  ) async {
    try {
      List<String> uid = users.map((e) => e.id).toList();
      final response = await createAPICall('room/$id/invite', "put", {
        "users": uid,
      });

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
}
