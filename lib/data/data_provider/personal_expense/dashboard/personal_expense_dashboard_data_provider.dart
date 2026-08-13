import 'dart:convert';

import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class PersonalExpenseDashboardDataProvider {
  Future<Pair<List<PersonalExpenseInfoModel>, bool>> fetchData(
    DateTime cursor,
  ) async {
    try {
      final response = await createAPICall(
        'personal/all?${addCursorInURL(cursor)}',
        "get",
        {},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        bool hasMoreData = data['has_more'];
        final allTransactions = data['data'];
        List<PersonalExpenseInfoModel> arr = [];
        if (allTransactions != null) {
          for (int i = 0; i < allTransactions.length; i++) {
            arr.add(PersonalExpenseInfoModel.fromMap(allTransactions[i]));
          }
        }

        return Pair(arr, hasMoreData);
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }
}
