import 'dart:convert';

import 'package:settlenow/firebase/firebase_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class AuthDataProvider {
  Future<UserPreferenceBundle> loginUser(String email, String otp) async {
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

      Map<String, String> jsonInputData = {
        'email': email,
        'otp': otp,
        'device': deviceInfo['device']!,
        'fcm_token': fcmToken,
        'user_agent': deviceInfo['userAgent']!,
        'version': deviceInfo['version']!,
        'ip': deviceIP,
      };

      final response = await createAPICall('auth/otp', "patch", jsonInputData);

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        AuthModel authData = SessionManager.instance.getAuth().fromMap(data);
        await SessionManager.instance.setAuth(authData);

        final userInfoData = await getOwnUserInfo();
        return userInfoData;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserPreferenceBundle> signupUsingGoogle(
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

      Map<String, String> jsonInputData = {
        'idToken': idToken,
        'device': deviceInfo['device']!,
        'fcm_token': fcmToken,
        'user_agent': deviceInfo['userAgent']!,
        'version': deviceInfo['version']!,
        'ip': deviceIP,
      };

      final response = await createAPICall(
        'auth/signup/google',
        "post",
        jsonInputData,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        AuthModel authData = SessionManager.instance.getAuth().fromMap(data);
        await SessionManager.instance.setAuth(authData);

        final userInfoData = await getOwnUserInfo();
        return userInfoData;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserPreferenceBundle> loginUsingGoogle(
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

      Map<String, String> jsonInputData = {
        'idToken': idToken,
        'device': deviceInfo['device']!,
        'fcm_token': fcmToken,
        'user_agent': deviceInfo['userAgent']!,
        'version': deviceInfo['version']!,
        'ip': deviceIP,
      };

      final response = await createAPICall(
        'auth/googleLogin',
        "post",
        jsonInputData,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        AuthModel authData = SessionManager.instance.getAuth().fromMap(data);
        await SessionManager.instance.setAuth(authData);

        final userInfoData = await getOwnUserInfo();
        return userInfoData;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> refreshToken() async {
    try {
      final ip = await fetchIP();
      final authData = SessionManager.instance.getAuth();

      final response = await createAPICall('auth/refresh', "post", {
        "refresh_token": authData.refreshToken,
        "ip": ip,
      });

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        AuthModel newAuthData = authData.fromMap(data);
        await SessionManager.instance.setAuth(newAuthData);

        return newAuthData.accessToken;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserPreferenceBundle> getOwnUserInfo() async {
    try {
      String version = await getAppVersion();
      final response = await createAPICall(
        'auth/info?version=${Uri.encodeQueryComponent(version)}',
        "get",
        {},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        UserModel userData = UserModel.forOwnerInfo(data);
        PreferenceModel preferenceData = PreferenceModel.fromJson(
          data['preference'],
        );
        final allFriends = data['friends'];
        List<UserModel> allFriendsArr = [];
        if (allFriends != null) {
          for (int i = 0; i < allFriends.length; i++) {
            allFriendsArr.add(UserModel.fromBasicInfoMap(allFriends[i]));
          }
        }

        return (
          user: userData,
          preference: preferenceData,
          friends: allFriendsArr,
        );
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUpUser(String name, String email) async {
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

      final response = await createAPICall('auth/signup', "post", {
        'name': name,
        'email': email,
        'fcm_token': fcmToken,
        'user_agent': deviceInfo['userAgent']!,
        'version': deviceInfo['version']!,
        'ip': deviceIP,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendOTP(String email) async {
    try {
      Map<String, String> jsonInputData = {'email': email};
      final response = await createAPICall('auth/otp', "post", jsonInputData);

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

  Future<void> logoutUser() async {
    try {
      final response = await createAPICall('auth/logout', "get", {});
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

  Future<void> deleteAccount() async {
    try {
      final response = await createAPICall('user', "delete", {});

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

  Future<bool> logoutDifferentDevice(String sessionID) async {
    try {
      final response = await createAPICall(
        'auth/logout?id=${Uri.encodeQueryComponent(sessionID)}',
        "get",
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

  Future<List<LoginActivityModel>> fetchLoginActivity() async {
    try {
      final response = await createAPICall('auth/login_activity', "get", {});

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

  Future<List<UserModel>> fetchFriend() async {
    try {
      final response = await createAPICall('friend', "get", {});

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

  Future<void> savePreference(PreferenceModel preferenceData) async {
    try {
      final response = await createAPICall(
        'user/preference',
        "patch",
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
