import 'package:settlenow_v2/data/data_provider/notification_data_provider.dart';
import 'package:settlenow_v2/model/notification_model.dart';

class NotificationRepository {
  final NotificationDataProvider _dataProvider;

  NotificationRepository(this._dataProvider);

  Future<List<NotificationModel>> fetchData(String authToken) async {
    try {
      List<NotificationModel> data = await _dataProvider.fetchData(authToken);
      data.sort((a, b) => b.createdOn.compareTo(a.createdOn));
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> acceptInvite(String id, String authToken) async {
    try {
      await _dataProvider.acceptInvite(id, authToken);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> declineInvite(String id, String authToken) async {
    try {
      await Future.delayed(Duration(seconds: 5));
      await _dataProvider.declineInvite(id, authToken);
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
