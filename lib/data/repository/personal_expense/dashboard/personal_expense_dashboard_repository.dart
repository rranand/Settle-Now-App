import 'package:settlenow/data/data_provider/personal_expense/dashboard/personal_expense_dashboard_data_provider.dart';
import 'package:settlenow/model/personal_expense_info_model.dart';

class PersonalExpenseDashboardRepository {
  final PersonalExpenseDashboardDataProvider _dataProvider;

  PersonalExpenseDashboardRepository(this._dataProvider);

  Future<Map<int, List<PersonalExpenseInfoModel>>> fetchData(
    int alreadyHave,
    String authToken,
  ) async {
    try {
      List<PersonalExpenseInfoModel> data = await _dataProvider.fetchData(
        alreadyHave,
        authToken,
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
