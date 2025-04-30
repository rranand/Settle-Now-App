import 'dart:convert';

import 'package:settlenow_v2/model/personal_expense_info_model.dart';

class PersonalExpenseDashboardDataProvider {
  Future<List<PersonalExpenseInfoModel>> fetchData(String email) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      String dataStr =
          '''[{"id":"expense001","amount":1234.5,"monthName":"January","year":"2025","transaction":[200,300,734.5]},{"id":"expense002","amount":875.75,"monthName":"February","year":"2025","transaction":[400,475.75]},{"id":"expense003","amount":1500,"monthName":"April","year":"2025","transaction":[500,500,500]},{"id":"expense004","amount":940.2,"monthName":"March","year":"2024","transaction":[300,320.2,320]},{"id":"expense005","amount":670,"monthName":"May","year":"2024","transaction":[170,250,250]},{"id":"expense006","amount":1520.8,"monthName":"August","year":"2024","transaction":[520.8,500,500]},{"id":"expense007","amount":425,"monthName":"November","year":"2023","transaction":[200,225]},{"id":"expense008","amount":980.3,"monthName":"December","year":"2023","transaction":[480.3,500]},{"id":"expense009","amount":600,"monthName":"July","year":"2023","transaction":[300,300]},{"id":"expense010","amount":1290,"monthName":"September","year":"2023","transaction":[645,645]},{"id":"expense011","amount":450.5,"monthName":"June","year":"2025","transaction":[150.25,300.25]}]
''';

      List<dynamic> tempArr = jsonDecode(dataStr);
      List<PersonalExpenseInfoModel> arr =
          tempArr.map((ele) => PersonalExpenseInfoModel.fromMap(ele)).toList();

      return arr;
    } catch (e) {
      rethrow;
    }
  }
}
