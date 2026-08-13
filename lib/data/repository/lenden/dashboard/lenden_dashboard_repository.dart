import 'package:settlenow/data/data_provider/data_provider_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class LendenDashboardRepository {
  final LendenDashboardDataProvider _dataProvider;

  LendenDashboardRepository(this._dataProvider);

  Future<Pair<List<LendenDashboardModel>, bool>> fetchData(
    DateTime cursor,
  ) async {
    try {
      return await _dataProvider.fetchData(cursor);
    } catch (e) {
      rethrow;
    }
  }

  Future<LendenDashboardModel> createRoom(LendenDashboardModel roomData) async {
    try {
      LendenDashboardModel data = await _dataProvider.createRoom(roomData);
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
