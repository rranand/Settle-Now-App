import 'dart:convert';

import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/model/room_settle_model.dart';
import 'package:settlenow_v2/model/room_user_model.dart';

class RoomDataProvider {
  Future<List<TransactionModel>> fetchData(String email, String id) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      String dataStr = '''
[
  {
    "id": "t1",
    "description": "Groceries",
    "amount": 45.50,
    "category": "Food",
    "createdBy": {
      "id": "user_1",
      "name": "John Doe",
      "email": "john@example.com",
      "profileImage": "https://picsum.photos/id/23/200/300",
      "amount": 0
    },
    "users": [],
    "createdOn": "2023-05-15T10:30:00Z",
    "modifiedOn": "2023-05-15T10:30:00Z"
  },
  {
    "id": "t2",
    "description": "Movie tickets",
    "amount": 60.00,
    "category": "Entertainment",
    "createdBy": {
      "id": "u2",
      "name": "Alice Smith",
      "email": "alice@example.com",
      "profileImage": "https://picsum.photos/id/45/200/300",
      "amount": 20.00
    },
    "users": [
      {
        "id": "user_1",
        "name": "John Doe",
        "email": "john@example.com",
        "profileImage": "https://picsum.photos/id/23/200/300",
        "amount": 20.00
      },
      {
        "id": "u3",
        "name": "Bob Johnson",
        "email": "bob@example.com",
        "profileImage": "https://picsum.photos/id/67/200/300",
        "amount": 20.00
      }
    ],
    "createdOn": "2023-05-16T18:15:00Z",
    "modifiedOn": "2023-05-16T18:15:00Z"
  },
  {
    "id": "t3",
    "description": "Dinner",
    "amount": 120.75,
    "category": "Food",
    "createdBy": {
      "id": "u3",
      "name": "Bob Johnson",
      "email": "bob@example.com",
      "profileImage": "https://picsum.photos/id/67/200/300",
      "amount": 40.25
    },
    "users": [
      {
        "id": "user_1",
        "name": "John Doe",
        "email": "john@example.com",
        "profileImage": "https://picsum.photos/id/23/200/300",
        "amount": 40.25
      },
      {
        "id": "u2",
        "name": "Alice Smith",
        "email": "alice@example.com",
        "profileImage": "https://picsum.photos/id/45/200/300",
        "amount": 40.25
      }
    ],
    "createdOn": "2023-05-17T20:45:00Z",
    "modifiedOn": "2023-05-17T20:45:00Z"
  },
  {
    "id": "t4",
    "description": "Taxi ride",
    "amount": 35.20,
    "category": "Transport",
    "createdBy": {
      "id": "u4",
      "name": "Eve Wilson",
      "email": "eve@example.com",
      "profileImage": "https://picsum.photos/id/89/200/300",
      "amount": 35.20
    },
    "users": [],
    "createdOn": "2023-05-18T09:10:00Z",
    "modifiedOn": "2023-05-18T09:10:00Z"
  },
  {
    "id": "t5",
    "description": "Concert tickets",
    "amount": 250.00,
    "category": "Entertainment",
    "createdBy": {
      "id": "user_1",
      "name": "John Doe",
      "email": "john@example.com",
      "profileImage": "https://picsum.photos/id/23/200/300",
      "amount": 125.00
    },
    "users": [
      {
        "id": "u2",
        "name": "Alice Smith",
        "email": "alice@example.com",
        "profileImage": "https://picsum.photos/id/45/200/300",
        "amount": 125.00
      }
    ],
    "createdOn": "2023-05-19T15:20:00Z",
    "modifiedOn": "2023-05-19T15:20:00Z"
  },
  {
    "id": "t6",
    "description": "Weekend trip",
    "amount": 480.50,
    "category": "Travel",
    "createdBy": {
      "id": "u2",
      "name": "Alice Smith",
      "email": "alice@example.com",
      "profileImage": "https://picsum.photos/id/45/200/300",
      "amount": 120.125
    },
    "users": [
      {
        "id": "user_1",
        "name": "John Doe",
        "email": "john@example.com",
        "profileImage": "https://picsum.photos/id/23/200/300",
        "amount": 120.125
      },
      {
        "id": "u3",
        "name": "Bob Johnson",
        "email": "bob@example.com",
        "profileImage": "https://picsum.photos/id/67/200/300",
        "amount": 120.125
      },
      {
        "id": "u4",
        "name": "Eve Wilson",
        "email": "eve@example.com",
        "profileImage": "https://picsum.photos/id/89/200/300",
        "amount": 120.125
      }
    ],
    "createdOn": "2023-05-20T08:00:00Z",
    "modifiedOn": "2023-05-20T08:00:00Z"
  },
  {
    "id": "t7",
    "description": "Books",
    "amount": 75.30,
    "category": "Education",
    "createdBy": {
      "id": "u3",
      "name": "Bob Johnson",
      "email": "bob@example.com",
      "profileImage": "https://picsum.photos/id/67/200/300",
      "amount": 0
    },
    "users": [],
    "createdOn": "2023-05-21T14:25:00Z",
    "modifiedOn": "2023-05-21T14:25:00Z"
  },
  {
    "id": "t8",
    "description": "Gym membership",
    "amount": 90.00,
    "category": "Health",
    "createdBy": {
      "id": "u4",
      "name": "Eve Wilson",
      "email": "eve@example.com",
      "profileImage": "https://picsum.photos/id/89/200/300",
      "amount": 90.00
    },
    "users": [],
    "createdOn": "2023-05-22T11:40:00Z",
    "modifiedOn": "2023-05-22T11:40:00Z"
  },
  {
    "id": "t9",
    "description": "Coffee",
    "amount": 12.50,
    "category": "Food",
    "createdBy": {
      "id": "user_1",
      "name": "John Doe",
      "email": "john@example.com",
      "profileImage": "https://picsum.photos/id/23/200/300",
      "amount": 6.25
    },
    "users": [
      {
        "id": "u3",
        "name": "Bob Johnson",
        "email": "bob@example.com",
        "profileImage": "https://picsum.photos/id/67/200/300",
        "amount": 6.25
      }
    ],
    "createdOn": "2023-05-23T16:05:00Z",
    "modifiedOn": "2023-05-23T16:05:00Z"
  },
  {
    "id": "t10",
    "description": "Phone bill",
    "amount": 65.00,
    "category": "Utilities",
    "createdBy": {
      "id": "u2",
      "name": "Alice Smith",
      "email": "alice@example.com",
      "profileImage": "https://picsum.photos/id/45/200/300",
      "amount": 65.00
    },
    "users": [],
    "createdOn": "2023-05-24T09:15:00Z",
    "modifiedOn": "2023-05-24T09:15:00Z"
  },
  {
    "id": "t11",
    "description": "Birthday gift",
    "amount": 85.00,
    "category": "Gifts",
    "createdBy": {
      "id": "u3",
      "name": "Bob Johnson",
      "email": "bob@example.com",
      "profileImage": "https://picsum.photos/id/67/200/300",
      "amount": 42.50
    },
    "users": [
      {
        "id": "user_1",
        "name": "John Doe",
        "email": "john@example.com",
        "profileImage": "https://picsum.photos/id/23/200/300",
        "amount": 42.50
      }
    ],
    "createdOn": "2023-05-25T19:30:00Z",
    "modifiedOn": "2023-05-25T19:30:00Z"
  },
  {
    "id": "t12",
    "description": "Internet bill",
    "amount": 70.00,
    "category": "Utilities",
    "createdBy": {
      "id": "u4",
      "name": "Eve Wilson",
      "email": "eve@example.com",
      "profileImage": "https://picsum.photos/id/89/200/300",
      "amount": 35.00
    },
    "users": [
      {
        "id": "u2",
        "name": "Alice Smith",
        "email": "alice@example.com",
        "profileImage": "https://picsum.photos/id/45/200/300",
        "amount": 35.00
      }
    ],
    "createdOn": "2023-05-26T13:20:00Z",
    "modifiedOn": "2023-05-26T13:20:00Z"
  }
]
          ''';

      List<dynamic> tempArr = jsonDecode(dataStr);
      List<TransactionModel> arr =
          tempArr.map((ele) => TransactionModel.fromMap(ele)).toList();

      return arr;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<RoomUserModel>> fetchUserData(String email, String id) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      String dataStr = '''
      [
  {
    "id": "ru1",
    "user": {
      "id": "user_1",
      "name": "John Doe",
      "profileImage": "https://picsum.photos/id/23/200/300"
    },
    "contribution": 150.75,
    "spent": 120.50
  },
  {
    "id": "ru2",
    "user": {
      "id": "u2",
      "name": "Alice Smith",
      "profileImage": "https://picsum.photos/id/45/200/300"
    },
    "contribution": 0,
    "spent": 85.00
  },
  {
    "id": "ru3",
    "user": {
      "id": "u3",
      "name": "Bob Johnson",
      "profileImage": "https://picsum.photos/id/67/200/300"
    },
    "contribution": 200.00,
    "spent": 200.00
  },
  {
    "id": "ru4",
    "user": {
      "id": "u4",
      "name": "Eve Wilson",
      "profileImage": "https://picsum.photos/id/89/200/300"
    },
    "contribution": 75.50,
    "spent": 0
  },
  {
    "id": "ru5",
    "user": {
      "id": "u5",
      "name": "Mike Brown",
      "profileImage": "https://picsum.photos/id/12/200/300"
    },
    "contribution": 300.25,
    "spent": 275.75
  },
  {
    "id": "ru6",
    "user": {
      "id": "u6",
      "name": "Sarah Davis",
      "profileImage": "https://picsum.photos/id/34/200/300"
    },
    "contribution": 0,
    "spent": 0
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

  Future<List<RoomSettleModel>> fetchSettleData(String email, String id) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      String dataStr = '''
      [
  {
    "id": "settle_001",
    "recevier": {
      "id": "user_1",
      "name": "Rohit Anand",
      "profileImage": "https://picsum.photos/id/11/200/300"
    },
    "sender": {
      "id": "user_102",
      "name": "Aman Mehra",
      "profileImage": "https://picsum.photos/id/12/200/300"
    },
    "amount": 350.0,
    "createdOn": "2024-12-01T10:30:00Z",
    "modifiedOn": "2024-12-01T12:00:00Z"
  },
  {
    "id": "settle_002",
    "recevier": {
      "id": "user_1",
      "name": "Rohit Anand",
      "profileImage": "https://picsum.photos/id/13/200/300"
    },
    "sender": {
      "id": "user_104",
      "name": "Rahul Singh",
      "profileImage": "https://picsum.photos/id/14/200/300"
    },
    "amount": -1200.0,
    "createdOn": "2024-11-28T09:15:00Z",
    "modifiedOn": "2024-11-28T09:45:00Z"
  },
  {
    "id": "settle_003",
    "recevier": {
      "id": "user_105",
      "name": "Sneha Kapoor",
      "profileImage": "https://picsum.photos/id/15/200/300"
    },
    "sender": {
      "id": "user_1",
      "name": "Rohit Anand",
      "profileImage": "https://picsum.photos/id/16/200/300"
    },
    "amount": 560.0,
    "createdOn": "2024-10-20T14:00:00Z",
    "modifiedOn": "2024-10-20T15:00:00Z"
  },
  {
    "id": "settle_004",
    "recevier": {
      "id": "user_107",
      "name": "Priya Dutta",
      "profileImage": "https://picsum.photos/id/17/200/300"
    },
    "sender": {
      "id": "user_108",
      "name": "Kunal Joshi",
      "profileImage": "https://picsum.photos/id/18/200/300"
    },
    "amount": 890.0,
    "createdOn": "2025-01-05T11:20:00Z",
    "modifiedOn": "2025-01-05T11:50:00Z"
  }
]


    ''';
      List<dynamic> tempArr = jsonDecode(dataStr);
      List<RoomSettleModel> arr =
          tempArr.map((ele) => RoomSettleModel.fromMap(ele)).toList();

      return arr;
    } catch (e) {
      rethrow;
    }
  }
}
