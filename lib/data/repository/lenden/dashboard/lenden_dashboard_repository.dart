import 'package:settlenow_v2/data/data_provider/lenden/dashboard/lenden_dashboard_data_provider.dart';
import 'package:settlenow_v2/model/lenden_dashboard_model.dart';

class LendenDashboardRepository {
  final LendenDashboardDataProvider _dataProvider;

  LendenDashboardRepository(this._dataProvider);

  Future<List<LendenDashboardModel>> fetchData(String email) async {
    try {
      return _dataProvider.fetchData(email);
    } catch (e) {
      rethrow;
    }
  }
}
