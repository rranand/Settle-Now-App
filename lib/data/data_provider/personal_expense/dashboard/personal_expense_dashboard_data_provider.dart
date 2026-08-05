import 'dart:convert';

import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class PersonalExpenseDashboardDataProvider {
  Future<List<PersonalExpenseInfoModel>> fetchData(int alreadyHave) async {
    try {
      final response = await createAPICall(
        'personal/all?alreadyHave=${Uri.encodeQueryComponent(alreadyHave.toString())}',
        "get",
        {},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final allTransactions = data['data'];
        List<PersonalExpenseInfoModel> arr = [];
        if (allTransactions != null) {
          for (int i = 0; i < allTransactions.length; i++) {
            arr.add(PersonalExpenseInfoModel.fromMap(allTransactions[i]));
          }
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
