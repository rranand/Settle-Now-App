import 'dart:convert';

import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class QuicksplitDataProvider {
  Future<Pair<List<QuicksplitTransactionModel>, bool>> fetchData(
    int alreadyHave,
  ) async {
    try {
      final response = await createAPICall(
        'quicksplit?alreadyHave=$alreadyHave',
        "get",
        {},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        bool hasMore = data['has_more'];
        List<QuicksplitTransactionModel> arr = [];
        final allTransactions = data['data'];
        if (allTransactions != null) {
          for (int i = 0; i < allTransactions.length; i++) {
            arr.add(QuicksplitTransactionModel.fromMap(allTransactions[i]));
          }
        }

        return Pair(arr, hasMore);
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<QuicksplitTransactionModel> create(
    QuicksplitTransactionModel data,
  ) async {
    try {
      final response = await createAPICall(
        'quicksplit',
        "post",
        data.toCreateExpenseJson(),
      );

      final respData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data.copyWith(id: respData['data']['id']);
      } else {
        throw respData['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> update(QuicksplitTransactionModel data) async {
    try {
      final response = await createAPICall(
        'quicksplit',
        "put",
        data.toUpdateExpenseJson(),
      );

      final respData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return;
      } else {
        throw respData['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> delete(String expenseID) async {
    try {
      final response = await createAPICall('quicksplit', "delete", {
        "id": expenseID,
      });

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return true;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addToPersonalExpense(String expenseID) async {
    try {
      final response = await createAPICall(
        'quicksplit/personalExpense',
        "post",
        {"id": expenseID},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return true;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> settleExpense(String expenseID) async {
    try {
      final response = await createAPICall('quicksplit/settle', "patch", {
        "id": expenseID,
      });

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> optout(String expenseID) async {
    try {
      final response = await createAPICall('quicksplit/optout', "patch", {
        "id": expenseID,
      });

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }
}
