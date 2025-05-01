import 'dart:convert';

import 'package:settlenow_v2/core.dart';

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
      "id": "u1",
      "name": "John Doe",
      "email": "john@example.com",
      "profileImage": "https://picsum.photos/id/23/200/300",
      "amount": 45.50
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
      "amount": 60.00
    },
    "users": [
      {
        "id": "u1",
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
      },
      {
        "id": "u4",
        "name": "Eve Wilson",
        "email": "eve@example.com",
        "profileImage": "https://picsum.photos/id/89/200/300",
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
      "amount": 120.75
    },
    "users": [
      {
        "id": "u1",
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
      },
      {
        "id": "u3",
        "name": "Bob Johnson",
        "email": "bob@example.com",
        "profileImage": "https://picsum.photos/id/67/200/300",
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
      "id": "u1",
      "name": "John Doe",
      "email": "john@example.com",
      "profileImage": "https://picsum.photos/id/23/200/300",
      "amount": 250.00
    },
    "users": [
      {
        "id": "u1",
        "name": "John Doe",
        "email": "john@example.com",
        "profileImage": "https://picsum.photos/id/23/200/300",
        "amount": 125.00
      },
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
      "amount": 480.50
    },
    "users": [
      {
        "id": "u1",
        "name": "John Doe",
        "email": "john@example.com",
        "profileImage": "https://picsum.photos/id/23/200/300",
        "amount": 120.125
      },
      {
        "id": "u2",
        "name": "Alice Smith",
        "email": "alice@example.com",
        "profileImage": "https://picsum.photos/id/45/200/300",
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
      "amount": 75.30
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
    "users": [
      {
        "id": "u4",
        "name": "Eve Wilson",
        "email": "eve@example.com",
        "profileImage": "https://picsum.photos/id/89/200/300",
        "amount": 90.00
      }
    ],
    "createdOn": "2023-05-22T11:40:00Z",
    "modifiedOn": "2023-05-22T11:40:00Z"
  },
  {
    "id": "t9",
    "description": "Coffee",
    "amount": 12.50,
    "category": "Food",
    "createdBy": {
      "id": "u1",
      "name": "John Doe",
      "email": "john@example.com",
      "profileImage": "https://picsum.photos/id/23/200/300",
      "amount": 12.50
    },
    "users": [
      {
        "id": "u1",
        "name": "John Doe",
        "email": "john@example.com",
        "profileImage": "https://picsum.photos/id/23/200/300",
        "amount": 6.25
      },
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
      "amount": 85.00
    },
    "users": [
      {
        "id": "u1",
        "name": "John Doe",
        "email": "john@example.com",
        "profileImage": "https://picsum.photos/id/23/200/300",
        "amount": 42.50
      },
      {
        "id": "u3",
        "name": "Bob Johnson",
        "email": "bob@example.com",
        "profileImage": "https://picsum.photos/id/67/200/300",
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
      "amount": 70.00
    },
    "users": [
      {
        "id": "u2",
        "name": "Alice Smith",
        "email": "alice@example.com",
        "profileImage": "https://picsum.photos/id/45/200/300",
        "amount": 35.00
      },
      {
        "id": "u4",
        "name": "Eve Wilson",
        "email": "eve@example.com",
        "profileImage": "https://picsum.photos/id/89/200/300",
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
}
