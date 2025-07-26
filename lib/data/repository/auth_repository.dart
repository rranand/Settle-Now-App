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
      //await Future.delayed(Duration(seconds: 2));
      //throw "Unauthorized Access";
      String? authToken = await LocalStoragePreference.getStringPref(
        'auth_token',
      );
      authToken =
          "njEThyz062WOpb6dn1JywizMmnBjxMg0hKBpO2tHNc2HMq8aGTzRKSHQ/T93Cn8a64pTVWcWM4DOvB6mTp1cO4hmEGqHFgOpDSGAHSOKdpftfyOUDKbaWTuSt0A/VXe+lO5hJj4hvkdaOff+YqPCOe1/qY3E6ktmoVYwdB45NeOg/KDFz7tAHNae9I1RvMrQeqjU+ZUbbV6bpJnlyfzWzawa+SEVvT54YvA7ZlRJfuz9oTu3yXvWfKe/JezhamDM7OdAsSFoRSXqatai2tOrCGa94MrEV4taDMaZ3uiX/m2pfZuw/Vbeikrj+bNxSEOhTLTQ3/SKDpBa7/RYfPENknKz14sDc9nWwcmy5HLNkLsF2NKUFS7BNWi4Vyj6Udipj6RvO3/BUNrD90AwJog6MdDs7deDQwUZaLxQOV6JeJKDhUolQ/Jhdlk/38WqOCNlER7ZjBw+gx0VW8weqIJTenHgKP2KR1Bk7HSDQUBYd/xG2wuXk6hybNNCswVcqxgb8N/dpfDdivGr9TCGVuiPYcAM1IYzH9+M+vW9+GhH/yhCuFRCv9DP/IoNACWBzZTQqCnGVEbivn9zLUclmVQ5/mOZNYHecH++jDk1MUoY3AvkkQ/QQFg2NGJUq4A2xOq9yEwLSRP+R4jRdLiWQ9cRxcmiMNNsqUQZi3Cfgyf1Jdief3MeMOKJWtYcDvcYQOdcD/LtH3CBINlrge4Jpq4jzeRsNIhuRNxEfPes7nJOKaQBTmUX5zmwmPigA42ZH7BNkvoblcLofj4ryGN9e8RQLrJzRSEdwyaFttxnTUPfVAgcImPa87KH8vLSjAdbuxTECNqy1cbtM26u21FaXD8BoZ0l+TU3jmJVZveZstsXSoCvN6QJAvZV1o+MvibdEjYtLs9+dynjlYqDDCD+iwTL8NwFNcgJYzBpCZOQRR0ERJa/KyiFrvs5qr4FShRWmItQyyGUv1mtY9+UvJrAWs2qoRUaRDJxHocEuCVSuNJhSMwPrQduk5UiPEqTjrNteXQMvZbh9E3neHgayDEk1LVTUxBX7MPJoHF3W/ym4zND2gJ6D418TxPVmVoFzVdCD9U60nuj3VBmwRgEZA/D1L5SFzWKBWbmbLsHZ5HmHWnwSRNvz8VXHEqDid0P8lGuev8kX3cBxJVNt6sCA/qHHWmNcudlqJ1+Lh5f2IOHiV3HfhMVLv+cOxW+QgMR/bRWFOrZX8Qcg975pCLKEaBNvd1YfRmQDvjEwz9Sc7EF6tw+ZHSzcawHUYch14kwGwFjPEFFMfiVKj7ucjCL0PAKGJGlpzxHXHbSKwgB55KRsB1cx5OzWdF9tv/pKxXZ0A7rf3Xgf6wvCxBmh03hUygCYTC1zwIMcOiMkSNKrsIyXuptkFDUSQo4Jd6tnvP3kInIXR+ig0Gf4fgs7V7j+jSA2WU1/f16NH8y3q9k7darixamspOHNAJNYqv89ju/lBaMD6mcDZZBqNLm/yZRNz+apzvDyksPBanWHfd4pxdz/+oJfECxMrThi5A5t96mNVxKmTk0";

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
