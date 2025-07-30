import 'package:settlenow_v2/data/data_provider/auth_data_provider.dart';
import 'package:settlenow_v2/model/login_activity_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/util/handler/crypto.dart';
import 'package:settlenow_v2/util/handler/local_storage_preference.dart';

class AuthRepository {
  final AuthDataProvider _dataProvider;
  AuthRepository(this._dataProvider);

  Future<UserModel> getLoggedInUser() async {
    try {
      String? authToken = await LocalStoragePreference.getStringPref(
        'auth_token',
      );

      if (authToken == null) {
        throw "Unauthorized Access";
      }
      final UserModel userData = await _dataProvider.getOwnUserInfo(authToken);
      return userData;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> loginUser(String email, String otp) async {
    try {
      final UserModel loginData = await _dataProvider.loginUser(email, otp);
      return loginData;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> loginUsingGoogle(String email, String idToken) async {
    try {
      final UserModel loginData = await _dataProvider.loginUsingGoogle(
        email,
        idToken,
      );
      return loginData;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> signupUsingGoogle(String email, String idToken) async {
    try {
      final UserModel loginData = await _dataProvider.signupUsingGoogle(
        email,
        idToken,
      );
      return loginData;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> signUpUser(String name, String email) async {
    try {
      final signupToken = await _dataProvider.signUpUser(name, email);

      return signupToken;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> sendOTP(String email) async {
    try {
      final isOTPSend = await _dataProvider.sendOTP(email);
      return isOTPSend;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> sendSignupOTP(String token) async {
    try {
      final isOTPSend = await _dataProvider.sendSignupOTP(token);
      return isOTPSend;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> validateSignupOTP(String token, String otp) async {
    try {
      final userData = await _dataProvider.validateSignupOTP(token, otp);

      return userData;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logoutUser(String authToken) async {
    try {
      await _dataProvider.logoutUser(authToken);
      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount(String authToken) async {
    try {
      await _dataProvider.deleteAccount(authToken);
      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> logoutDifferentDevice(String authToken, String sessionID) async {
    try {
      final isLogoutSuccessful = await _dataProvider.logoutDifferentDevice(
        authToken,
        Crypto.encrypt(sessionID),
      );
      return isLogoutSuccessful;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LoginActivityModel>> fetchLoginActivity(String authToken) async {
    try {
      final List<LoginActivityModel> loginActivityData = await _dataProvider
          .fetchLoginActivity(authToken);
      loginActivityData.sort(
        (a, b) => b.lastLoggedIn.compareTo(a.lastLoggedIn),
      );
      return loginActivityData;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile(UserModel userData) async {
    try {
      await _dataProvider.updateProfile(userData);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> fetchFriend(String authToken) async {
    try {
      final List<UserModel> data = await _dataProvider.fetchFriend(authToken);
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
