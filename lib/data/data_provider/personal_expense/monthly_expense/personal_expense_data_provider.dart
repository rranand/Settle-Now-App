import 'dart:convert';

import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class PersonalMonthlyExpenseDataProvider {
  Future<List<PersonalExpenseTransactionModel>> fetchData(
    String year,
    String month,
  ) async {
    try {
      final response = await createAPICall('personal/$year/$month', "get", {});

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final allData = data['data'];
        List<PersonalExpenseTransactionModel> arr = [];
        if (allData != null) {
          for (int i = 0; i < allData.length; i++) {
            arr.add(PersonalExpenseTransactionModel.fromMap(allData[i]));
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

  Future<PersonalExpenseTransactionModel> add(
    PersonalExpenseTransactionModel expenseData,
  ) async {
    try {
      final response = await createAPICall(
        'personal',
        "post",
        expenseData.toCreateExpenseJson(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return expenseData.copyWith(id: data['data']['id']);
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> update(PersonalExpenseTransactionModel expenseData) async {
    try {
      final response = await createAPICall(
        'personal',
        'put',
        expenseData.toUpdateExpenseJson(),
      );

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

  Future<bool> delete(String expenseID, TransactionType transactionType) async {
    try {
      final response = await createAPICall('personal', 'delete', {
        "id": expenseID,
        "transaction_type": transactionType.label,
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
}
