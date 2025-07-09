import 'dart:convert';

import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/model/new_transaction_model.dart';
import 'package:settlenow_v2/model/notification_model.dart';
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

  Future<LendenTransactionModel> create(
    String id,
    String authToken,
    NewTransactionModel expenseData,
  ) async {
    try {
      LendenTransactionModel newExpense =
          LendenTransactionModel.fromNewTransaction(expenseData);
      final response = await createAPICall(
        'lenden/$id',
        "post",
        authToken,
        newExpense.toCreateExpenseJson(),
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

  Future<LendenTransactionModel> update(
    String id,
    String authToken,
    NewTransactionModel expenseData,
  ) async {
    try {
      LendenTransactionModel newExpense =
          LendenTransactionModel.fromNewTransaction(expenseData);
      final response = await createAPICall(
        'lenden/$id',
        "patch",
        authToken,
        newExpense.toUpdateExpenseJson(),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        newExpense.modifiedOn = DateTime.now();
        return newExpense;
      } else {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> delete(String id, String authToken, String expenseID) async {
    try {
      final response = await createAPICall('lenden/$id', "delete", authToken, {
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

  Future<bool> closeRoom(String roomID, String authToken) async {
    try {
      final response = await createAPICall(
        'lenden/$roomID',
        "put",
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

  Future<NotificationModel> inviteUser(
    String roomID,
    String uid,
    String authToken,
  ) async {
    try {
      final response = await createAPICall(
        'lenden/$roomID',
        'patch',
        authToken,
        {"id": Crypto.encrypt(uid)},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        NotificationModel notificationData = NotificationModel.fromMap(
          data['data'],
        );
        return notificationData;
      } else {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}
