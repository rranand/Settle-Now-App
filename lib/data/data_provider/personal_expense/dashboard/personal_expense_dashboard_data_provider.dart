import 'dart:convert';

import 'package:settlenow/model/personal_expense_info_model.dart';
import 'package:settlenow/util/handler/network_call.dart';

class PersonalExpenseDashboardDataProvider {
  Future<List<PersonalExpenseInfoModel>> fetchData(
    int alreadyHave,
    String authToken,
  ) async {
    try {
      final response = await createAPICall(
        'personal/all?alreadyHave=${Uri.encodeQueryComponent(alreadyHave.toString())}',
        "get",
        authToken,
        {},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<PersonalExpenseInfoModel> arr = [];
        for (int i = 0; i < data['data'].length; i++) {
          arr.add(PersonalExpenseInfoModel.fromMap(data['data'][i]));
        }
        return arr;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }
}
