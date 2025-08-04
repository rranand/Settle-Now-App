import 'dart:convert';

import 'package:settlenow_v2/model/new_transaction_model.dart';
import 'package:settlenow_v2/model/transaction_model.dart';
import 'package:settlenow_v2/util/handler/crypto.dart';
import 'package:settlenow_v2/util/handler/network_call.dart';

class QuicksplitDataProvider {
  Future<List<TransactionModel>> fetchData(String authToken) async {
    try {
      final response = await createAPICall('quicksplit', "get", authToken, {});

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<TransactionModel> arr = [];
        for (int i = 0; i < data['data'].length; i++) {
          arr.add(TransactionModel.fromMap(data['data'][i]));
        }
        return arr;
      } else {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<TransactionModel> create(
    NewTransactionModel data,
    String authToken,
  ) async {
    try {
      TransactionModel newExpense = TransactionModel.fromNewTransaction(data);

      final response = await createAPICall(
        'quicksplit',
        "post",
        authToken,
        newExpense.toQuickSplitJson(),
      );

      final respData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        newExpense.id = Crypto.decrypt(respData['data']['id']);
        return newExpense;
      } else {
        throw Crypto.decrypt(respData['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<TransactionModel> update(
    NewTransactionModel data,
    String authToken,
  ) async {
    try {
      TransactionModel updatedExpense = TransactionModel.fromNewTransaction(
        data,
      );
      updatedExpense.modifiedOn = DateTime.now();

      final response = await createAPICall(
        'quicksplit',
        "put",
        authToken,
        updatedExpense.toQuickSplitJson(),
      );

      final respData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return updatedExpense;
      } else {
        throw Crypto.decrypt(respData['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> delete(String expenseID, String authToken) async {
    try {
      final response = await createAPICall('quicksplit', "delete", authToken, {
        "id": Crypto.encrypt(expenseID),
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

  Future<bool> addToPersonalExpense(String expenseID, String authToken) async {
    try {
      final response = await createAPICall(
        'quicksplit/personalExpense',
        "post",
        authToken,
        {"id": Crypto.encrypt(expenseID)},
      );

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

  Future<void> settleExpense(String expenseID, String authToken) async {
    try {
      final response = await createAPICall(
        'quicksplit/settle',
        "patch",
        authToken,
        {"id": Crypto.encrypt(expenseID)},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return;
      } else {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> optout(String expenseID, String authToken) async {
    try {
      final response = await createAPICall(
        'quicksplit/optout',
        "patch",
        authToken,
        {"id": Crypto.encrypt(expenseID)},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return;
      } else {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}
