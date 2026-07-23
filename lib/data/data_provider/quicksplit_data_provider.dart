import 'dart:convert';

import 'package:settlenow/model/new_transaction_model.dart';
import 'package:settlenow/model/transaction_model.dart';
import 'package:settlenow/util/handler/network_call.dart';

class QuicksplitDataProvider {
  Future<List<TransactionModel>> fetchData() async {
    try {
      final response = await createAPICall('quicksplit', "get", {});

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<TransactionModel> arr = [];
        for (int i = 0; i < data['data'].length; i++) {
          arr.add(TransactionModel.fromMap(data['data'][i]));
        }
        return arr;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<TransactionModel> create(NewTransactionModel data) async {
    try {
      TransactionModel newExpense = TransactionModel.fromNewTransaction(data);

      final response = await createAPICall(
        'quicksplit',
        "post",
        newExpense.toQuickSplitJson(),
      );

      final respData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        newExpense.id = respData['data']['id'];
        return newExpense;
      } else {
        throw respData['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<TransactionModel> update(NewTransactionModel data) async {
    try {
      TransactionModel updatedExpense = TransactionModel.fromNewTransaction(
        data,
      );
      updatedExpense.modifiedOn = DateTime.now();

      final response = await createAPICall(
        'quicksplit',
        "put",
        updatedExpense.toQuickSplitJson(),
      );

      final respData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return updatedExpense;
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
