import 'package:settlenow/data/data_provider/data_provider_core.dart';
import 'package:settlenow/model/model_core.dart';

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
