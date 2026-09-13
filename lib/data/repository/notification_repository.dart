import 'package:settlenow/data/data_provider/data_provider_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class NotificationRepository {
  final NotificationDataProvider _dataProvider;

  NotificationRepository(this._dataProvider);

  Future<List<NotificationModel>> fetchData() async {
    try {
      return await _dataProvider.fetchData();
    } catch (e) {
      rethrow;
    }
  }

  Future<Pair<List<ActivityNotificationModel>, bool>> fetchActivityBasedNotifications(
    DateTime cursor,
  ) async {
    try {
      return await _dataProvider.fetchActivityBasedNotifications(cursor);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> unreadActivityNotificationCount() async {
    try {
      return await _dataProvider.unreadActivityNotificationCount();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllAsRead(DateTime recentlyReadTimestamp) async {
    try {
      return await _dataProvider.markAllAsRead(recentlyReadTimestamp);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(List<String> ids) async {
    try {
      return await _dataProvider.markAsRead(ids);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acceptInvite(String id) async {
    try {
      await _dataProvider.acceptInvite(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> declineInvite(String id) async {
    try {
      await _dataProvider.declineInvite(id);
    } catch (e) {
      rethrow;
    }
  }
}
