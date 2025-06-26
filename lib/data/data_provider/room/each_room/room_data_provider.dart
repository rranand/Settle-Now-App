import 'dart:convert';

import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/model/new_transaction_model.dart';
import 'package:settlenow_v2/model/room_settle_model.dart';
import 'package:settlenow_v2/util/handler/crypto.dart';
import 'package:settlenow_v2/util/handler/network_call.dart';

class RoomDataProvider {
  Future<RoomInfoModel> fetchRoomInfo(String id, String authToken) async {
    try {
      final response = await createAPICall(
        'room/info/$id',
        "get",
        authToken,
        {},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        RoomInfoModel roomData = RoomInfoModel.fromMap(data['data']);
        return roomData;
      } else {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TransactionModel>> fetchData(String id, String authToken) async {
    try {
      final response = await createAPICall(
        'room/$id/transaction',
        "get",
        authToken,
        {},
      );

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

  Future<List<RoomSettleModel>> fetchSettleData(
    String id,
    String authToken,
  ) async {
    try {
      final response = await createAPICall(
        'room/$id/settle',
        "get",
        authToken,
        {},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<RoomSettleModel> arr = [];
        for (int i = 0; i < data['data'].length; i++) {
          arr.add(RoomSettleModel.fromMap(data['data'][i]));
        }
        return arr;
      } else {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> closeRoomRequest(String id, String authToken) async {
    try {
      final response = await createAPICall(
        'room/close/$id/request',
        "get",
        authToken,
        {},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<TransactionModel> createExpense(NewTransactionModel data) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      TransactionModel newExpense = TransactionModel.fromNewTransaction(data);
      newExpense.id = "${newExpense.description}##${newExpense.createdOn}";
      return newExpense;
    } catch (e) {
      rethrow;
    }
  }

  Future<TransactionModel> updateExpense(NewTransactionModel data) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      TransactionModel updatedExpense = TransactionModel.fromNewTransaction(
        data,
      );
      updatedExpense.modifiedOn = DateTime.now();
      return updatedExpense;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteExpense(String expenseID) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<RoomSettleModel> createNewSettleExpense(RoomSettleModel data) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      data.id = "${data.createdOn}##${data.amount}";
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<RoomSettleModel> updateSettleExpense(RoomSettleModel data) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      data.modifiedOn = DateTime.now();
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteSettleExpense(String expenseID) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
