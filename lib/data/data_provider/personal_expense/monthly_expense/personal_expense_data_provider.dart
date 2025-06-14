import 'dart:convert';

import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/model/new_transaction_model.dart';
import 'package:settlenow_v2/util/handler/crypto.dart';
import 'package:settlenow_v2/util/handler/network_call.dart';

class PersonalMonthlyExpenseDataProvider {
  Future<List<PersonalExpenseTransactionModel>> fetchData(
    String authToken,
    String year,
    String month,
  ) async {
    try {
      final response = await createAPICall(
        'personal/$year/$month',
        "get",
        authToken,
        {},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<PersonalExpenseTransactionModel> arr = [];
        for (int i = 0; i < data['data'].length; i++) {
          arr.add(PersonalExpenseTransactionModel.fromMap(data['data'][i]));
        }
        return arr;
      } else {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<PersonalExpenseTransactionModel> add(NewTransactionModel data) async {
    try {
      PersonalExpenseTransactionModel newExpense =
          PersonalExpenseTransactionModel.fromNewTransaction(data);
      newExpense.id = "${newExpense.description}##${newExpense.createdOn}";
      return newExpense;
    } catch (e) {
      rethrow;
    }
  }

  Future<PersonalExpenseTransactionModel> update(
    NewTransactionModel data,
  ) async {
    try {
      PersonalExpenseTransactionModel updatedExpense =
          PersonalExpenseTransactionModel.fromNewTransaction(data);
      updatedExpense.modifiedOn = DateTime.now();
      return updatedExpense;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> delete(String expenseID) async {
    try {
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
