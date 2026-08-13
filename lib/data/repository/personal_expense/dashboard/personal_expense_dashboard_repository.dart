import 'package:settlenow/data/data_provider/data_provider_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class PersonalExpenseDashboardRepository {
  final PersonalExpenseDashboardDataProvider _dataProvider;

  PersonalExpenseDashboardRepository(this._dataProvider);

  Future<Pair<List<PersonalExpenseInfoModel>, bool>> fetchData(
    DateTime cursor,
  ) async {
    try {
      return await _dataProvider.fetchData(cursor);
    } catch (e) {
      rethrow;
    }
  }
}
