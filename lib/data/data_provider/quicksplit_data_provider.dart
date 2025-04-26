import 'dart:convert';

import 'package:settlenow_v2/model/quicksplit_model.dart';

class QuicksplitDataProvider {
  Future<List<QuickSplitModel>> fetchData(String email) async {
    try {
      await Future.delayed(Duration(milliseconds: 1500));
      String dataStr = '''[
  {
    "id": "1",
    "description": "Dinner at Italian place",
    "amount": 120.5,
    "tags": ["dinner", "friends"],
    "category": "Food & Dining",
    "createdBy": {
      "id": "u1",
      "name": "Alice Johnson",
      "email": "alice@example.com",
      "profileImage": "https://picsum.photos/id/10/200/300",
      "amount": 0.0
    },
    "users": [
      {
        "id": "u2",
        "name": "Bob Smith",
        "email": "bob@example.com",
        "profileImage": "https://picsum.photos/id/11/200/300",
        "amount": 40.17
      },
      {
        "id": "u3",
        "name": "Charlie Lee",
        "email": "charlie@example.com",
        "profileImage": "https://picsum.photos/id/12/200/300",
        "amount": 80.33
      }
    ],
    "createdOn": "2024-04-25T19:00:00.000Z",
    "modifiedOn": "2024-04-25T19:10:00.000Z"
  },
  {
    "id": "2",
    "description": "Netflix Subscription",
    "amount": 15.0,
    "tags": ["subscription"],
    "category": "Entertainment",
    "createdBy": {
      "id": "u4",
      "name": "David Wright",
      "email": "david@example.com",
      "profileImage": "https://picsum.photos/id/13/200/300",
      "amount": 5.0
    },
    "users": [
      {
        "id": "u5",
        "name": "Eve Stone",
        "email": "eve@example.com",
        "profileImage": "https://picsum.photos/id/14/200/300",
        "amount": 10.0
      }
    ],
    "createdOn": "2024-04-20T10:00:00.000Z",
    "modifiedOn": "2024-04-20T10:05:00.000Z"
  },
  {
    "id": "3",
    "description": "Taxi ride",
    "amount": 25.75,
    "tags": ["travel", "taxi"],
    "category": "Transportation",
    "createdBy": {
      "id": "u6",
      "name": "Fiona Clark",
      "email": "fiona@example.com",
      "profileImage": "https://picsum.photos/id/15/200/300",
      "amount": 0.0
    },
    "users": [
      {
        "id": "u7",
        "name": "George Baker",
        "email": "george@example.com",
        "profileImage": "https://picsum.photos/id/16/200/300",
        "amount": 25.75
      }
    ],
    "createdOn": "2024-04-22T14:30:00.000Z",
    "modifiedOn": "2024-04-22T14:45:00.000Z"
  },
  {
    "id": "4",
    "description": "Monthly Rent",
    "amount": 500.0,
    "tags": ["rent"],
    "category": "Housing",
    "createdBy": {
      "id": "u8",
      "name": "Henry Adams",
      "email": "henry@example.com",
      "profileImage": "https://picsum.photos/id/17/200/300",
      "amount": 100.0
    },
    "users": [
      {
        "id": "u9",
        "name": "Irene Watts",
        "email": "irene@example.com",
        "profileImage": "https://picsum.photos/id/18/200/300",
        "amount": 200.0
      },
      {
        "id": "u10",
        "name": "Jack Dawson",
        "email": "jack@example.com",
        "profileImage": "https://picsum.photos/id/19/200/300",
        "amount": 200.0
      }
    ],
    "createdOn": "2024-04-01T00:00:00.000Z",
    "modifiedOn": "2024-04-01T00:10:00.000Z"
  }
]
''';

      List<dynamic> tempArr = jsonDecode(dataStr);
      List<QuickSplitModel> arr =
          tempArr.map((ele) => QuickSplitModel.fromMap(ele)).toList();

      return arr;
    } catch (e) {
      rethrow;
    }
  }
}
