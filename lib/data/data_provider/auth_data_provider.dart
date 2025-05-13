import 'dart:convert';

import 'package:settlenow_v2/model/login_activity_model.dart';
import 'package:settlenow_v2/model/user_model.dart';

class AuthDataProvider {
  Future<String> loginUser(String username, String password) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      UserModel userData = UserModel.fromBasicInfo(
        name: 'Rohit Anand',
        id: 'rranand',
        profileImage: "https://picsum.photos/id/5/200/300",
      );

      return userData.toJson();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> signUpUser(String name, String email) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});

      return true;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> sendOTP(String email) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});

      return true;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> logoutUser(String uid, String sessionToken) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});

      return true;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<LoginActivityModel>> fetchLoginActivity(
    String uid,
    String sessionToken,
  ) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});

      String data = '''
      [
  {
    "id": "a1f9d2e3",
    "deviceName": "Pixel 7",
    "deviceType": "Mobile",
    "lastLoggedIn": "2025-05-13T08:32:45Z",
    "createdOn": "2025-01-23T13:14:10Z"
  },
  {
    "id": "",
    "deviceName": "iPhone 13 Pro",
    "deviceType": "Mobile",
    "lastLoggedIn": "2025-05-12T19:44:22Z",
    "createdOn": "2024-12-10T11:05:36Z"
  },
  {
    "id": "d7e2a3c4",
    "deviceName": "MacBook Air M1",
    "deviceType": "macOS",
    "lastLoggedIn": "2025-05-11T15:23:00Z",
    "createdOn": "2024-11-20T08:12:00Z"
  },
  {
    "id": "e1b2c3d4",
    "deviceName": "Samsung Galaxy S22",
    "deviceType": "Mobile",
    "lastLoggedIn": "2025-05-10T10:10:10Z",
    "createdOn": "2025-02-01T14:00:00Z"
  },
  {
    "id": "f3a4d5b6",
    "deviceName": "iPad Pro 12.9",
    "deviceType": "Mobile",
    "lastLoggedIn": "2025-05-09T06:45:30Z",
    "createdOn": "2025-01-15T18:30:00Z"
  },
  {
    "id": "g5h6j7k8",
    "deviceName": "Dell XPS 15",
    "deviceType": "Web",
    "lastLoggedIn": "2025-05-08T17:00:00Z",
    "createdOn": "2024-12-01T09:00:00Z"
  },
  {
    "id": "h9i8j7k6",
    "deviceName": "OnePlus 11",
    "deviceType": "Mobile",
    "lastLoggedIn": "2025-05-07T21:30:00Z",
    "createdOn": "2025-02-10T11:11:11Z"
  },
  {
    "id": "z1x2c3v4",
    "deviceName": "iMac 24",
    "deviceType": "macOS",
    "lastLoggedIn": "2025-05-06T08:15:00Z",
    "createdOn": "2024-10-25T13:45:00Z"
  },
  {
    "id": "l3m4n5o6",
    "deviceName": "Realme GT Neo 3",
    "deviceType": "Mobile",
    "lastLoggedIn": "2025-05-05T12:00:00Z",
    "createdOn": "2024-11-11T16:20:00Z"
  },
  {
    "id": "u1v2w3x4",
    "deviceName": "iPhone SE",
    "deviceType": "Mobile",
    "lastLoggedIn": "2025-05-04T14:40:00Z",
    "createdOn": "2024-09-30T10:10:10Z"
  }
]


''';

      List<dynamic> dataArr = jsonDecode(data);
      List<LoginActivityModel> arr =
          dataArr.map((ele) => LoginActivityModel.fromMap(ele)).toList();

      return arr;
    } catch (e) {
      throw e.toString();
    }
  }
}
