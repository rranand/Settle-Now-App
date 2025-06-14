import 'dart:convert';

import 'package:settlenow_v2/model/personal_expense_info_model.dart';
import 'package:settlenow_v2/util/handler/crypto.dart';
import 'package:settlenow_v2/util/handler/network_call.dart';

class PersonalExpenseDashboardDataProvider {
  Future<List<PersonalExpenseInfoModel>> fetchData(
    int alreadyHave,
    String authToken,
  ) async {
    try {
      final response = await createAPICall(
        'personal/dashboard?alreadyHave=${Uri.encodeQueryComponent(alreadyHave.toString())}',
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
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}
