import 'package:settlenow/data/data_provider/lenden/dashboard/lenden_dashboard_data_provider.dart';
import 'package:settlenow/model/lenden_dashboard_model.dart';

class LendenDashboardRepository {
  final LendenDashboardDataProvider _dataProvider;

  LendenDashboardRepository(this._dataProvider);

  Future<List<LendenDashboardModel>> fetchData(String authToken) async {
    try {
      List<LendenDashboardModel> data = await _dataProvider.fetchData(
        authToken,
      );
      data.sort((a, b) => b.createdOn.compareTo(a.createdOn));
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<LendenDashboardModel> createRoom(
    LendenDashboardModel roomData,
    String authToken,
  ) async {
    try {
      LendenDashboardModel data = await _dataProvider.createRoom(
        roomData,
        authToken,
      );
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
