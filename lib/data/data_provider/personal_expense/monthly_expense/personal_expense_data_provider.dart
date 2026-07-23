import 'dart:convert';

import 'package:settlenow/core.dart';
import 'package:settlenow/model/new_transaction_model.dart';
import 'package:settlenow/util/handler/network_call.dart';

class PersonalMonthlyExpenseDataProvider {
  Future<List<PersonalExpenseTransactionModel>> fetchData(
    String year,
    String month,
  ) async {
    try {
      final response = await createAPICall(
        'personal/$year/$month',
        "get",
        
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
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<PersonalExpenseTransactionModel> add(
    NewTransactionModel expenseData,
  ) async {
    try {
      PersonalExpenseTransactionModel newExpense =
          PersonalExpenseTransactionModel.fromNewTransaction(expenseData);

      final response = await createAPICall(
        'personal',
        "post",
        
        newExpense.toCreateNewExpenseJson(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        newExpense.id = data['data']['id'];
        return newExpense;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<PersonalExpenseTransactionModel> update(
    NewTransactionModel expenseData,
  ) async {
    try {
      PersonalExpenseTransactionModel updatedExpense =
          PersonalExpenseTransactionModel.fromNewTransaction(expenseData);
      final response = await createAPICall(
        'personal',
        'put',
        
        updatedExpense.toCreateNewExpenseJson(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        updatedExpense.modifiedOn = DateTime.now();
        return updatedExpense;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> delete(
    String expenseID,
    String transactionType,
  ) async {
    try {
      final response = await createAPICall('personal', 'delete',  {
        "id": expenseID,
        "transactionType": transactionType,
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
