import 'dart:convert';

import 'package:settlenow_v2/firebase/firebase_messaging.dart';
import 'package:settlenow_v2/model/login_activity_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/util/handler/crypto.dart';
import 'package:settlenow_v2/util/handler/network_call.dart';
import 'package:settlenow_v2/util/handler/platform_service.dart';
import 'package:settlenow_v2/util/handler/sharedPrefParse.dart';

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
        'version': Crypto.encrypt(deviceInfo['version']!),
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

  Future<UserModel> loginUsingGoogle(String email, String idToken) async {
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

      final String token = Crypto.encrypt("$email#@#$idToken");

      Map<String, String> jsonInputData = {
        'idToken': Crypto.encrypt(idToken),
        'token': Crypto.encrypt(token),
        'device': Crypto.encrypt(deviceInfo['device']!),
        'deviceToken': Crypto.encrypt(fcmToken),
        'userAgent': Crypto.encrypt(deviceInfo['userAgent']!),
        'version': Crypto.encrypt(deviceInfo['version']!),
        'ip': Crypto.encrypt(deviceIP),
      };

      final response = await createAPICall(
        'auth/googleLogin',
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
      String version = await getAppVersion();
      final response = await createAPICall('auth', "patch", authToken, {
        'version': Crypto.encrypt(version),
      });
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        UserModel userData = UserModel.forOwnerInfo(data['data'], authToken);

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
      final response = await createAPICall('auth/signup', "post", "", {
        'name': Crypto.encrypt(name),
        'email': Crypto.encrypt(email),
        'token': Crypto.encrypt(token),
        'device': Crypto.encrypt(deviceInfo['device']!),
        'deviceToken': Crypto.encrypt(fcmToken),
        'userAgent': Crypto.encrypt(deviceInfo['userAgent']!),
        'version': Crypto.encrypt(deviceInfo['version']!),
        'ip': Crypto.encrypt(deviceIP),
      });

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

  //TODO: Update Profile
  Future<bool> updateProfile(UserModel userData) async {
    try {
      await Future.delayed(Duration(seconds: 2));
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> fetchFriend(String authToken) async {
    try {
      final response = await createAPICall('friend', "get", authToken, {});

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<UserModel> arr = [];
        for (int i = 0; i < data['data'].length; i++) {
          arr.add(UserModel.fromBasicInfoMap(data['data'][i]));
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
