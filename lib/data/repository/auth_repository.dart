import 'package:settlenow_v2/data/data_provider/auth_data_provider.dart';
import 'package:settlenow_v2/model/login_activity_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/util/handler/crypto.dart';
import 'package:settlenow_v2/util/handler/sharedPrefParse.dart';

class AuthRepository {
  final AuthDataProvider _dataProvider;
  AuthRepository(this._dataProvider);

  Future<UserModel> getLoggedInUser() async {
    try {
      String? authToken = await getStringPref('auth_token');
      if (authToken == null) {
        return UserModel.empty();
      }
      // authToken =
      //     "XinviKc2AiEyvlfJugaFBwUYFsX2e3PX6R1/uGL8zOH/xuekF4zb4dTVjWvD2yRUYGSFR2FO7ZWNuN0Nrj8UiQ==";
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

  Future<bool> logoutUser(String authToken) async {
    try {
      final isLogoutSuccessful = await _dataProvider.logoutUser(authToken);
      return isLogoutSuccessful;
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

  Future<bool> updateProfile(UserModel userData) async {
    try {
      final bool isUpdated = await _dataProvider.updateProfile(userData);
      return isUpdated;
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
