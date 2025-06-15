import 'dart:convert';

import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/model/new_transaction_model.dart';
import 'package:settlenow_v2/util/handler/crypto.dart';
import 'package:settlenow_v2/util/handler/network_call.dart';

class LendenRoomDataProvider {
  Future<Pair<LendenDashboardModel, List<LendenTransactionModel>>> fetchData(
    String id,
    String authToken,
  ) async {
    try {
      final response = await createAPICall('lenden/$id', "get", authToken, {});

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        LendenDashboardModel roomData = LendenDashboardModel.fromMap(
          data['data'],
        );
        List<LendenTransactionModel> arr = [];
        for (int i = 0; i < data['data']['transaction'].length; i++) {
          arr.add(
            LendenTransactionModel.fromMap(
              data['data']['transaction'][i],
              roomData.users,
            ),
          );
        }
        return Pair(roomData, arr);
      } else {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<LendenTransactionModel> create(NewTransactionModel data) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      LendenTransactionModel newExpense =
          LendenTransactionModel.fromNewTransaction(data);
      return newExpense;
    } catch (e) {
      rethrow;
    }
  }

  Future<LendenTransactionModel> update(NewTransactionModel data) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      LendenTransactionModel updatedExpense =
          LendenTransactionModel.fromNewTransaction(data);
      updatedExpense.modifiedOn = DateTime.now();
      return updatedExpense;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> delete(String expenseID) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> closeRoom(String roomID, String authToken) async {
    try {
      final response = await createAPICall(
        'lenden/$roomID',
        "delete",
        authToken,
        {},
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
}
