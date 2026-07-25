import 'package:settlenow/data/data_provider/data_provider_core.dart';
import 'package:settlenow/model/model_core.dart';

class PersonalExpenseDashboardRepository {
  final PersonalExpenseDashboardDataProvider _dataProvider;

  PersonalExpenseDashboardRepository(this._dataProvider);

  Future<Map<int, List<PersonalExpenseInfoModel>>> fetchData(
    int alreadyHave,
  ) async {
    try {
      List<PersonalExpenseInfoModel> data = await _dataProvider.fetchData(
        alreadyHave,
      );

      Map<int, List<PersonalExpenseInfoModel>> yearWiseExpense = {};

      for (int i = 0; i < data.length; i++) {
        int curYear = int.parse(data[i].year);
        if (yearWiseExpense.containsKey(curYear)) {
          yearWiseExpense[curYear]!.add(data[i]);
        } else {
          yearWiseExpense[curYear] = [data[i]];
        }
      }
      return yearWiseExpense;
    } catch (e) {
      rethrow;
    }
  }
}
