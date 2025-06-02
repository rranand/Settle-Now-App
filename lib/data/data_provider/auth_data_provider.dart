import 'dart:convert';

import 'package:settlenow_v2/firebase/firebase_messaging.dart';
import 'package:settlenow_v2/model/login_activity_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/util/handler/crypto.dart';
import 'package:settlenow_v2/util/handler/network_call.dart';
import 'package:settlenow_v2/util/handler/platform_service.dart';
import 'package:settlenow_v2/util/handler/sharedPrefParse.dart';

//TODO: Incase of failure, Success state data is not showing.

class AuthDataProvider {
  Future<UserModel> loginUser(String email, String otp) async {
    try {
      final deviceData = await Future.wait([
        generateFCMToken(),
        platformState(),
        fetchIP(),
      ]);
      final String fcmToken = deviceData[0] as String;
      final Map<String, String> deviceInfo =
          deviceData[1] as Map<String, String>;
      final String deviceIP = deviceData[2] as String;

      final String token = Crypto.encrypt(
        "$email#@#${deviceInfo['id']!}#@#${DateTime.now()}",
      );

      Map<String, String> jsonInputData = {
        'email': Crypto.encrypt(email),
        'otp': Crypto.encrypt(otp),
        'token': Crypto.encrypt(token),
        'device': Crypto.encrypt(deviceInfo['device']!),
        'deviceToken': Crypto.encrypt(fcmToken),
        'userAgent': Crypto.encrypt(deviceInfo['userAgent']!),
        'ip': Crypto.encrypt(deviceIP),
      };

      final response = await createAPICall(
        'auth/login',
        "post",
        "",
        jsonInputData,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final userInfoData = await Future.wait([
          setStringPref('auth_token', token),
          getOwnUserInfo(token),
        ]);

        return userInfoData[1] as UserModel;
      } else {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getOwnUserInfo(String authToken) async {
    try {
      final response = await createAPICall('auth', "get", authToken, {});
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        UserModel userData = UserModel.fromBasicInfo(
          id: Crypto.decrypt(data['data']['id']),
          name: Crypto.decrypt(data['data']['name']),
          profileImage: Crypto.decrypt(data['data']['profileImage']),
        );

        userData.phoneNo = Crypto.decrypt(data['data']['phoneNo']);
        userData.createdOn = DateTime.parse(
          Crypto.decrypt(data['data']['createdOn']),
        );
        userData.email = Crypto.decrypt(data['data']['email']);
        userData.authToken = authToken;
        return userData;
      } else {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> signUpUser(String name, String email) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> sendOTP(String email) async {
    try {
      Map<String, String> jsonInputData = {'email': Crypto.encrypt(email)};
      final response = await createAPICall(
        'auth/otp',
        "post",
        "",
        jsonInputData,
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

  Future<bool> logoutUser(String authToken) async {
    try {
      final response = await createAPICall('auth/logout', "get", authToken, {});
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

  Future<bool> logoutDifferentDevice(String authToken, String sessionID) async {
    try {
      final response = await createAPICall(
        'auth/logout?id=${Uri.encodeQueryComponent(sessionID)}',
        "get",
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

  Future<List<LoginActivityModel>> fetchLoginActivity(String authToken) async {
    try {
      final response = await createAPICall(
        'auth/login_activity',
        "get",
        authToken,
        {},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<LoginActivityModel> arr = [];
        for (int i = 0; i < data['data'].length; i++) {
          arr.add(LoginActivityModel.fromMap(data['data'][i]));
        }

        return arr;
      } else {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> updateProfile(UserModel userData) async {
    try {
      await Future.delayed(Duration(seconds: 2));
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
