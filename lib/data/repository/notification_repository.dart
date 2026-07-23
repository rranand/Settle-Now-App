import 'package:settlenow/data/data_provider/notification_data_provider.dart';
import 'package:settlenow/model/notification_model.dart';

class NotificationRepository {
  final NotificationDataProvider _dataProvider;

  NotificationRepository(this._dataProvider);

  Future<List<NotificationModel>> fetchData() async {
    try {
      List<NotificationModel> data = await _dataProvider.fetchData();
      data.sort((a, b) => b.createdOn.compareTo(a.createdOn));
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> acceptInvite(String id) async {
    try {
      await _dataProvider.acceptInvite(id);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> declineInvite(String id) async {
    try {
      await _dataProvider.declineInvite(id);
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
