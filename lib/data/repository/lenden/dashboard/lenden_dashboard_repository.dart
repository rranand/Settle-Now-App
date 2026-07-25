import 'package:settlenow/data/data_provider/data_provider_core.dart';
import 'package:settlenow/model/model_core.dart';

class LendenDashboardRepository {
  final LendenDashboardDataProvider _dataProvider;

  LendenDashboardRepository(this._dataProvider);

  Future<List<LendenDashboardModel>> fetchData(int alreadyHave) async {
    try {
      List<LendenDashboardModel> data = await _dataProvider.fetchData(
        alreadyHave,
      );
      data.sort((a, b) => b.createdOn.compareTo(a.createdOn));
      return data;
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
