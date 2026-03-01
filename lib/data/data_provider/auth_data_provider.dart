import 'dart:convert';

import 'package:settlenow/core.dart';
import 'package:settlenow/firebase/firebase_messaging.dart';
import 'package:settlenow/model/login_activity_model.dart';
import 'package:settlenow/model/preference_model.dart';
import 'package:settlenow/util/handler/network_call.dart';
import 'package:settlenow/util/handler/platform_service.dart';
import 'package:settlenow/util/handler/local_storage_preference.dart';

class AuthDataProvider {
  Future<Pair<UserModel, PreferenceModel>> loginUser(
    String email,
    String otp,
  ) async {
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

      final String token = "$email#@#${deviceInfo['id']!}#@#${DateTime.now()}";

      Map<String, String> jsonInputData = {
        'email': email,
        'otp': otp,
        'token': token,
        'device': deviceInfo['device']!,
        'deviceToken': fcmToken,
        'userAgent': deviceInfo['userAgent']!,
        'version': deviceInfo['version']!,
        'ip': deviceIP,
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
          LocalStoragePreference.setStringPref('auth_token', token),
          getOwnUserInfo(token),
        ]);

        Pair<UserModel, PreferenceModel> pairData =
            userInfoData[1] as Pair<UserModel, PreferenceModel>;

        return Pair(pairData.first, pairData.second);
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Pair<UserModel, PreferenceModel>> signupUsingGoogle(
    String email,
    String idToken,
  ) async {
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

      final String token = "$email#@#$idToken";

      Map<String, String> jsonInputData = {
        'idToken': idToken,
        'token': token,
        'device': deviceInfo['device']!,
        'deviceToken': fcmToken,
        'userAgent': deviceInfo['userAgent']!,
        'version': deviceInfo['version']!,
        'ip': deviceIP,
      };

      final response = await createAPICall(
        'auth/signup/google',
        "post",
        "",
        jsonInputData,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final userInfoData = await Future.wait([
          LocalStoragePreference.setStringPref('auth_token', token),
          getOwnUserInfo(token),
        ]);
        Pair<UserModel, PreferenceModel> pairData =
            userInfoData[1] as Pair<UserModel, PreferenceModel>;
        return pairData;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Pair<UserModel, PreferenceModel>> loginUsingGoogle(
    String email,
    String idToken,
  ) async {
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

      final String token = "$email#@#$idToken";

      Map<String, String> jsonInputData = {
        'idToken': idToken,
        'token': token,
        'device': deviceInfo['device']!,
        'deviceToken': fcmToken,
        'userAgent': deviceInfo['userAgent']!,
        'version': deviceInfo['version']!,
        'ip': deviceIP,
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
          LocalStoragePreference.setStringPref('auth_token', token),
          getOwnUserInfo(token),
        ]);
        Pair<UserModel, PreferenceModel> pairData =
            userInfoData[1] as Pair<UserModel, PreferenceModel>;
        return pairData;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Pair<UserModel, PreferenceModel>> getOwnUserInfo(
    String authToken,
  ) async {
    try {
      String version = await getAppVersion();
      final response = await createAPICall('auth', "patch", authToken, {
        'version': version,
      });
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        UserModel userData = UserModel.forOwnerInfo(data['data'], authToken);
        PreferenceModel preferenceData = PreferenceModel.fromJson(
          data['data']['preference'],
        );

        return Pair(userData, preferenceData);
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> signUpUser(String name, String email) async {
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

      final String token = "$email#@#${deviceInfo['id']!}#@#${DateTime.now()}";

      final response = await createAPICall('auth/signup', "post", "", {
        'name': name,
        'email': email,
        'token': token,
        'device': deviceInfo['device']!,
        'deviceToken': fcmToken,
        'userAgent': deviceInfo['userAgent']!,
        'version': deviceInfo['version']!,
        'ip': deviceIP,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return token;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> sendOTP(String email) async {
    try {
      Map<String, String> jsonInputData = {'email': email};
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
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> sendSignupOTP(String token) async {
    try {
      final response = await createAPICall('auth/signup/otp', "get", token, {});

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

  Future<Pair<UserModel, PreferenceModel>> validateSignupOTP(
    String token,
    String otp,
  ) async {
    try {
      final response = await createAPICall('auth/signup/otp', "patch", token, {
        "otp": otp,
      });

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final userInfoData = await Future.wait([
          LocalStoragePreference.setStringPref('auth_token', token),
          getOwnUserInfo(token),
        ]);
        Pair<UserModel, PreferenceModel> pairData =
            userInfoData[1] as Pair<UserModel, PreferenceModel>;
        return pairData;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logoutUser(String authToken) async {
    try {
      final response = await createAPICall('auth/logout', "get", authToken, {});
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

  Future<void> deleteAccount(String authToken) async {
    try {
      final response = await createAPICall('user', "delete", authToken, {});

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
        throw data['message'];
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
        throw data['message'];
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> updateProfile(UserModel userData) async {
    try {
      final response = await createAPICall(
        'user',
        "patch",
        userData.authToken,
        userData.updateProfileJSON(),
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
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> savePreference(
    PreferenceModel preferenceData,
    String authToken,
  ) async {
    try {
      final response = await createAPICall(
        'user/preference',
        "patch",
        authToken,
        preferenceData.toJson(),
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
}
