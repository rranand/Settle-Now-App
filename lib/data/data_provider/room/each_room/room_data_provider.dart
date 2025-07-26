import 'dart:convert';

import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/model/new_transaction_model.dart';
import 'package:settlenow_v2/model/notification_model.dart';
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

  Future<void> closeRoom(String id, String authToken) async {
    try {
      final response = await createAPICall(
        'room/close/$id',
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

  Future<void> updateRoom(
    String id,
    String authToken,
    String newRoomName,
  ) async {
    try {
      final response = await createAPICall(
        'room/$id/update',
        "patch",
        authToken,
        {"name": Crypto.encrypt(newRoomName)},
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

  Future<TransactionModel> createExpense(
    String id,
    NewTransactionModel data,
    String authToken,
  ) async {
    try {
      TransactionModel newExpense = TransactionModel.fromNewTransaction(data);

      final response = await createAPICall(
        'room/$id/transaction',
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

  Future<TransactionModel> updateExpense(
    String id,
    NewTransactionModel data,
    String expenseType,
    String authToken,
  ) async {
    try {
      TransactionModel newExpense = TransactionModel.fromNewTransaction(data);

      final response = await createAPICall(
        'room/$id/transaction',
        "patch",
        authToken,
        newExpense.toQuickSplitUpdateJson(
          extraData: {"splitType": Crypto.encrypt(expenseType)},
        ),
      );

      final respData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        newExpense.modifiedOn = DateTime.now();
        return newExpense;
      } else {
        throw Crypto.decrypt(respData['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteExpense(
    String id,
    String expenseID,
    String expenseType,
    String authToken,
  ) async {
    final response = await createAPICall(
      'room/$id/transaction',
      "delete",
      authToken,
      {
        "id": Crypto.encrypt(expenseID),
        "splitType": Crypto.encrypt(expenseType),
      },
    );

    final respData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Crypto.decrypt(respData['message']);
    }
  }

  Future<RoomSettleModel> createNewSettleExpense(
    String id,
    RoomSettleModel data,
    String authToken,
  ) async {
    try {
      final response = await createAPICall(
        'room/$id/settle',
        "post",
        authToken,
        data.toSettleTransactionJSON(),
      );

      final respData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        data.id = Crypto.decrypt(respData['data']['id']);
        return data;
      } else {
        throw Crypto.decrypt(respData['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<RoomSettleModel> updateSettleExpense(
    String id,
    RoomSettleModel data,
    String authToken,
  ) async {
    final response = await createAPICall(
      'room/$id/settle',
      "patch",
      authToken,
      data.toSettleTransactionJSON(),
    );

    final respData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      data.modifiedOn = DateTime.now();
      return data;
    } else {
      throw Crypto.decrypt(respData['message']);
    }
  }

  Future<bool> deleteSettleExpense(
    String id,
    String expenseID,
    String sender,
    String receiver,
    String authToken,
  ) async {
    final response =
        await createAPICall('room/$id/settle', "delete", authToken, {
          "id": Crypto.encrypt(expenseID),
          "sender": Crypto.encrypt(sender),
          "receiver": Crypto.encrypt(receiver),
        });

    final respData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Crypto.decrypt(respData['message']);
    }
  }

  Future<bool> addToPersonalExpense(
    String id,
    String expenseID,
    String splitType,
    String authToken,
  ) async {
    try {
      final response = await createAPICall(
        'room/$id/transaction/personalExpense',
        "post",
        authToken,
        {
          "id": Crypto.encrypt(expenseID),
          "splitType": Crypto.encrypt(splitType),
        },
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

  Future<List<NotificationModel>> inviteNewMember(
    String id,
    List<UserModel> users,
    String authToken,
  ) async {
    try {
      List<String> uid = users.map((e) => Crypto.encrypt(e.id)).toList();
      final response = await createAPICall(
        'room/invite/$id',
        "put",
        authToken,
        {"users": uid},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<NotificationModel> arr = [];
        for (int i = 0; i < data['data'].length; i++) {
          arr.add(NotificationModel.fromMap(data['data'][i]));
        }
        return arr;
      } else {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}
