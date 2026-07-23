import 'dart:convert';

import 'package:settlenow/core.dart';
import 'package:settlenow/model/new_transaction_model.dart';
import 'package:settlenow/model/notification_model.dart';
import 'package:settlenow/util/handler/network_call.dart';

class LendenRoomDataProvider {
  Future<Pair<LendenDashboardModel, List<LendenTransactionModel>>> fetchData(
    String id,
  ) async {
    try {
      final response = await createAPICall('lenden/$id', "get",  {});

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
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<LendenTransactionModel> create(
    String id,
    NewTransactionModel expenseData,
  ) async {
    try {
      LendenTransactionModel newExpense =
          LendenTransactionModel.fromNewTransaction(expenseData);
      final response = await createAPICall(
        'lenden/$id',
        "post",
        newExpense.toCreateExpenseJson(),
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

  Future<LendenTransactionModel> update(
    String id,
    NewTransactionModel expenseData,
  ) async {
    try {
      LendenTransactionModel newExpense =
          LendenTransactionModel.fromNewTransaction(expenseData);
      final response = await createAPICall(
        'lenden/$id',
        "patch",
        newExpense.toUpdateExpenseJson(),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        newExpense.modifiedOn = DateTime.now();
        return newExpense;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRoom(
    String id,
    String newRoomName,
  ) async {
    try {
      final response = await createAPICall(
        'lenden/$id/update',
        "put",
        {"name": newRoomName},
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

  Future<void> deleteRoom(String id, ) async {
    try {
      final response = await createAPICall(
        'lenden/$id/room',
        "delete",
        {},
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

  Future<bool> delete(String id, String expenseID) async {
    try {
      final response = await createAPICall('lenden/$id', "delete",  {
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

  Future<bool> closeRoom(String roomID, ) async {
    try {
      final response = await createAPICall(
        'lenden/$roomID',
        "put",
        {},
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

  Future<NotificationModel> inviteUser(
    String roomID,
    String uid,
  ) async {
    try {
      final response = await createAPICall(
        'lenden/$roomID/addPerson',
        'patch',
        
        {"id": uid},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        NotificationModel notificationData = NotificationModel.fromMap(
          data['data'],
        );
        return notificationData;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }
}
