import 'dart:convert';

import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class NotificationDataProvider {
  Future<List<NotificationModel>> fetchData() async {
    try {
      final response = await createAPICall('notification', "get", {});
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<NotificationModel> arr = [];
        final allNotification = data['data'];

        if (allNotification != null) {
          for (int i = 0; i < allNotification.length; i++) {
            arr.add(NotificationModel.fromMap(allNotification[i]));
          }
        }

        return arr;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Pair<List<ActivityNotificationModel>, bool>>
  fetchActivityBasedNotifications(DateTime cursor) async {
    try {
      final response = await createAPICall(
        'notification/activity?${addCursorInURL(cursor)}',
        "get",
        {},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<ActivityNotificationModel> arr = [];
        final allNotification = data['data'];

        if (allNotification != null) {
          for (int i = 0; i < allNotification.length; i++) {
            arr.add(ActivityNotificationModel.fromMap(allNotification[i]));
          }
        }

        return Pair(arr, data['has_more']);
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<int> unreadActivityNotificationCount() async {
    try {
      final response = await createAPICall(
        'notification/unread-count',
        "get",
        {},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data['data'];
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllAsRead(DateTime recentlyReadTimestamp) async {
    try {
      final response = await createAPICall('notification/read/all', "put", {
        "recentlyReadTimestamp": recentlyReadTimestamp.toIso8601String(),
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

  Future<void> markAsRead(List<String> ids) async {
    try {
      final response = await createAPICall('notification/read', "put", {
        "ids": ids,
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

  Future<void> acceptInvite(String id) async {
    try {
      final response = await createAPICall('notification', "put", {"id": id});
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

  Future<void> declineInvite(String id) async {
    try {
      final response = await createAPICall('notification', "delete", {
        "id": id,
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
}
