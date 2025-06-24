import 'dart:convert';

import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/model/new_transaction_model.dart';
import 'package:settlenow_v2/model/room_settle_model.dart';
import 'package:settlenow_v2/model/room_user_model.dart';
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

  Future<List<RoomUserModel>> fetchUserData(String id, String authToken) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      String dataStr = '''
      [
  {
    "id": "ru1",
    "user": {
      "id":"61e583aa96fca945d821c038",
      "name": "Rohit Anand",
      "email": "rrohitanand3336@gmail.com",
      "profileImage": "https://picsum.photos/id/23/200/300"
    },
    "contribution": 308,
    "spent": 120.50,
    "settle": 0
  },
  {
    "id": "ru2",
    "user": {
      "id": "u2",
      "name": "Alice Smith",
      "profileImage": "https://picsum.photos/id/45/200/300"
    },
    "contribution": 0,
    "spent": 85.00,
    "settle": 5.5
  },
  {
    "id": "ru3",
    "user": {
      "id": "u3",
      "name": "Bob Johnson",
      "profileImage": "https://picsum.photos/id/67/200/300"
    },
    "contribution": 200.00,
    "spent": 200.00,
    "settle": 0
  },
  {
    "id": "ru4",
    "user": {
      "id": "u4",
      "name": "Eve Wilson",
      "profileImage": "https://picsum.photos/id/89/200/300"
    },
    "contribution": 75.50,
    "spent": 0,
    "settle": -5.5
  },
  {
    "id": "ru5",
    "user": {
      "id": "u5",
      "name": "Mike Brown",
      "profileImage": "https://picsum.photos/id/12/200/300"
    },
    "contribution": 300.25,
    "spent": 275.75,
    "settle": 0
  },
  {
    "id": "ru6",
    "user": {
      "id": "u6",
      "name": "Sarah Davis",
      "profileImage": "https://picsum.photos/id/34/200/300"
    },
    "contribution": 0,
    "spent": 0,
    "settle": 0
  }
]

    ''';
      List<dynamic> tempArr = jsonDecode(dataStr);
      List<RoomUserModel> arr =
          tempArr.map((ele) => RoomUserModel.fromMap(ele)).toList();

      return arr;
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
