import 'dart:convert';

import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class LendenRoomDataProvider {
  Future<Tuple<LendenDashboardModel, List<LendenTransactionModel>, bool>>
  fetchData(String id) async {
    try {
      final response = await createAPICall('lenden/$id', "get", {});

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        LendenDashboardModel roomData = LendenDashboardModel.fromMap(
          data['data'],
        );
        bool hasMore = data['has_more'];
        List<LendenTransactionModel> arr = [];
        final allTransactions = data['data']['transactions'];

        if (allTransactions != null) {
          for (int i = 0; i < allTransactions.length; i++) {
            arr.add(LendenTransactionModel.fromMap(allTransactions[i]));
          }
        }

        return Tuple(roomData, arr, hasMore);
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<LendenTransactionModel> create(
    String id,
    LendenTransactionModel expenseData,
  ) async {
    try {
      final response = await createAPICall(
        'lenden/$id',
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

  Future<Pair<List<LendenTransactionModel>, bool>> fetchTransaction(
    String id,
    int alreadyHave,
    List<LendenUserModel> users,
  ) async {
    try {
      final response = await createAPICall(
        'lenden/$id/transactions?alreadyHave=$alreadyHave',
        "get",
        {},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        bool hasMore = data['has_more'];
        List<LendenTransactionModel> arr = [];
        final allTransactions = data['data'];

        if (allTransactions != null) {
          for (int i = 0; i < allTransactions.length; i++) {
            arr.add(LendenTransactionModel.fromMap(allTransactions[i]));
          }
        }

        return Pair(arr, hasMore);
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> update(String id, LendenTransactionModel expenseData) async {
    try {
      final response = await createAPICall(
        'lenden/$id',
        "patch",
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

  Future<void> updateRoom(String id, String newRoomName) async {
    try {
      final response = await createAPICall('lenden/$id/update', "put", {
        "name": newRoomName,
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

  Future<void> deleteRoom(String id) async {
    try {
      final response = await createAPICall('lenden/$id/room', "delete", {});

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
      final response = await createAPICall('lenden/$id', "delete", {
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

  Future<bool> closeRoom(String roomID) async {
    try {
      final response = await createAPICall('lenden/$roomID', "put", {});

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
    String roomId,
    String roomName,
    String uid,
  ) async {
    try {
      final response = await createAPICall(
        'lenden/$roomId/addPerson',
        'patch',
        {"id": uid},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        NotificationModel notificationData = NotificationModel.fromLendenMap(
          data['data'],
          roomId,
          roomName,
          uid,
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
