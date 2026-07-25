import 'package:settlenow/data/data_provider/data_provider_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class AuthRepository {
  final AuthDataProvider _dataProvider;
  AuthRepository(this._dataProvider);

  Future<Pair<UserModel, PreferenceModel>> getLoggedInUser() async {
    try {
      final Pair<UserModel, PreferenceModel> data =
          await _dataProvider.getOwnUserInfo();
      UserResolver.instance.loadFriends([data.first]);

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Pair<UserModel, PreferenceModel>> loginUser(
    String email,
    String otp,
  ) async {
    try {
      final Pair<UserModel, PreferenceModel> pairData = await _dataProvider
          .loginUser(email, otp);
      return pairData;
    } catch (e) {
      rethrow;
    }
  }

  Future<Pair<UserModel, PreferenceModel>> loginUsingGoogle(
    String email,
    String idToken,
  ) async {
    try {
      final loginData = await _dataProvider.loginUsingGoogle(email, idToken);
      return loginData;
    } catch (e) {
      rethrow;
    }
  }

  Future<Pair<UserModel, PreferenceModel>> signupUsingGoogle(
    String email,
    String idToken,
  ) async {
    try {
      final loginData = await _dataProvider.signupUsingGoogle(email, idToken);
      return loginData;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUpUser(String name, String email) async {
    try {
      await _dataProvider.signUpUser(name, email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendOTP(String email) async {
    try {
      await _dataProvider.sendOTP(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logoutUser() async {
    try {
      await _dataProvider.logoutUser();
      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _dataProvider.deleteAccount();
      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> logoutDifferentDevice(String sessionID) async {
    try {
      final isLogoutSuccessful = await _dataProvider.logoutDifferentDevice(
        sessionID,
      );
      return isLogoutSuccessful;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LoginActivityModel>> fetchLoginActivity() async {
    try {
      final List<LoginActivityModel> loginActivityData =
          await _dataProvider.fetchLoginActivity();
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

  Future<List<UserModel>> fetchFriend() async {
    try {
      final List<UserModel> data = await _dataProvider.fetchFriend();
      UserResolver.instance.loadFriends(data);

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> savePreference(PreferenceModel data) async {
    try {
      await _dataProvider.savePreference(data);
    } catch (e) {
      rethrow;
    }
  }
}
