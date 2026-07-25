import 'dart:convert';

import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class RoomDataProvider {
  Future<RoomInfoModel> fetchRoomInfo(String id) async {
    try {
      final response = await createAPICall('room/info/$id', "get", {});

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        RoomInfoModel roomData = RoomInfoModel.fromMap(data['data']);
        return roomData;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TransactionModel>> fetchData(String id) async {
    try {
      final response = await createAPICall('room/$id/transaction', "get", {});

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

  Future<List<RoomSettleModel>> fetchSettleData(String id) async {
    try {
      final response = await createAPICall('room/$id/settle', "get", {});

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<RoomSettleModel> arr = [];
        for (int i = 0; i < data['data'].length; i++) {
          arr.add(RoomSettleModel.fromMap(data['data'][i]));
        }
        return arr;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> closeRoomRequest(String id) async {
    try {
      final response = await createAPICall('room/close/$id/request', "get", {});

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> closeRoom(String id) async {
    try {
      final response = await createAPICall('room/close/$id', "get", {});

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRoom(String id, String newRoomName) async {
    try {
      final response = await createAPICall('room/$id/update', "patch", {
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
      final response = await createAPICall('room/$id', "delete", {});

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

  Future<TransactionModel> createExpense(
    String id,
    NewTransactionModel data,
  ) async {
    try {
      TransactionModel newExpense = TransactionModel.fromNewTransaction(data);

      final response = await createAPICall(
        'room/$id/transaction',
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

  Future<List<TransactionModel>> createBulkExpense(
    String id,
    List<NewTransactionModel> data,
  ) async {
    try {
      List<TransactionModel> newExpense = [];
      for (int i = 0; i < data.length; i++) {
        newExpense.add(TransactionModel.fromNewTransaction(data[i]));
      }
      final response = await createAPICall(
        'room/$id/bulk-transaction',
        "post",
        {"data": newExpense.toQuickSplitJson()},
      );

      final respData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final transactionMapping = respData['data'];
        for (int i = 0; i < data.length; i++) {
          newExpense[i].id = transactionMapping[i.toString()];
        }
        return newExpense;
      } else {
        throw respData['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<TransactionModel> updateExpense(
    String id,
    NewTransactionModel data,
  ) async {
    try {
      TransactionModel newExpense = TransactionModel.fromNewTransaction(data);

      final response = await createAPICall(
        'room/$id/transaction',
        "patch",
        newExpense.toQuickSplitUpdateJson(),
      );

      final respData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        newExpense.modifiedOn = DateTime.now();
        return newExpense;
      } else {
        throw respData['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteExpense(
    String id,
    String expenseID,
    String expenseType,
  ) async {
    final response = await createAPICall('room/$id/transaction', "delete", {
      "id": expenseID,
      "splitType": expenseType,
    });

    final respData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw respData['message'];
    }
  }

  Future<RoomSettleModel> createNewSettleExpense(
    String id,
    RoomSettleModel data,
  ) async {
    try {
      final response = await createAPICall(
        'room/$id/settle',
        "post",
        data.toSettleTransactionJSON(),
      );

      final respData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        data.id = respData['data']['id'];
        return data;
      } else {
        throw respData['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<RoomSettleModel> updateSettleExpense(
    String id,
    RoomSettleModel data,
  ) async {
    final response = await createAPICall(
      'room/$id/settle',
      "patch",
      data.toSettleTransactionJSON(),
    );

    final respData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      data.modifiedOn = DateTime.now();
      return data;
    } else {
      throw respData['message'];
    }
  }

  Future<bool> deleteSettleExpense(
    String id,
    String expenseID,
    String sender,
    String receiver,
  ) async {
    final response = await createAPICall('room/$id/settle', "delete", {
      "id": expenseID,
      "sender": sender,
      "receiver": receiver,
    });

    final respData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw respData['message'];
    }
  }

  Future<bool> addToPersonalExpense(String id, String expenseID) async {
    try {
      final response = await createAPICall(
        'room/$id/transaction/personalExpense',
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

  Future<List<NotificationModel>> inviteNewMember(
    String id,
    List<UserModel> users,
  ) async {
    try {
      List<String> uid = users.map((e) => e.id).toList();
      final response = await createAPICall('room/invite/$id', "put", {
        "users": uid,
      });

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<NotificationModel> arr = [];
        for (int i = 0; i < data['data'].length; i++) {
          arr.add(NotificationModel.fromMap(data['data'][i]));
        }
        return arr;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ActivityModel>> fetchActivity(String id) async {
    try {
      final response = await createAPICall('room/$id/activity', "get", {});

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<ActivityModel> arr = [];
        for (int i = 0; i < data['data'].length; i++) {
          arr.add(ActivityModel.fromMap(data['data'][i]));
        }
        return arr;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }
}
