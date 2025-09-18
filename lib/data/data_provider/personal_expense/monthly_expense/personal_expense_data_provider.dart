import 'dart:convert';

import 'package:settlenow/core.dart';
import 'package:settlenow/model/new_transaction_model.dart';
import 'package:settlenow/util/handler/crypto.dart';
import 'package:settlenow/util/handler/network_call.dart';

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

  Future<PersonalExpenseTransactionModel> add(
    String authToken,
    NewTransactionModel expenseData,
  ) async {
    try {
      PersonalExpenseTransactionModel newExpense =
          PersonalExpenseTransactionModel.fromNewTransaction(expenseData);

      final response = await createAPICall(
        'personal',
        "post",
        authToken,
        newExpense.toCreateNewExpenseJson(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        newExpense.id = Crypto.decrypt(data['data']['id']);
        return newExpense;
      } else {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<PersonalExpenseTransactionModel> update(
    String authToken,
    NewTransactionModel expenseData,
  ) async {
    try {
      PersonalExpenseTransactionModel updatedExpense =
          PersonalExpenseTransactionModel.fromNewTransaction(expenseData);
      final response = await createAPICall(
        'personal',
        'put',
        authToken,
        updatedExpense.toCreateNewExpenseJson(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        updatedExpense.modifiedOn = DateTime.now();
        return updatedExpense;
      } else {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> delete(
    String authToken,
    String expenseID,
    String transactionType,
  ) async {
    try {
      final response = await createAPICall('personal', 'delete', authToken, {
        "id": Crypto.encrypt(expenseID),
        "transactionType": Crypto.encrypt(transactionType),
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}
