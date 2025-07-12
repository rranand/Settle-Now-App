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
      // if (authToken == null) {
      //   return UserModel.empty();
      // }
      authToken =
          "njEThyz062WOpb6dn1JywizMmnBjxMg0hKBpO2tHNc2HMq8aGTzRKSHQ/T93Cn8aP1bq5PtiNU4KOzP7/w413JdxMJhvdaXmwltGwDFKllC6eSafw1saYmBOuz/7WYTVLoQAQsINt5/yRDEvCFmOdv8cgqOUiAmgOQK+v1UGg2YFPqRxkK5NvFKKVUR0Aw/YjazEty2xaPv/p+ZFchKdEv/SR9MjCmbO84LWnsp2XRaOvI1nYojP4WDZrt3cwY0cwCdb/ftfFulWrapjSKyIVF1HocDDa5A5ysuugpLtHRMKNcoNACg7D3W2ChVQ6O2Ddyl67uEt6SkpqTVGlYHVKJvaZf6qiEDdpF1EHEc75OBiG/eugVSlf/l1qMmYchDkgM6iXoi62LVz4zjDnMa1COmqKx5Us7S89h+NMIzP1GhX+u4aL52Qbp/v4bk1aQwSTG+rYKkcPrqgNMNbN4hSUSOfxYOVJls6SnB5V6RjFCCyS9B2It6i+qWV+u44BMYcd0+LFXt5/Ej8xaJs4HvpYOckRtk8zwIzOREwm7j3RNSAvJYnAFJQYzj7vtlcNS0U1XeEf1lFQJFUMqZ60wF/7cSUN3nLOX0AV9C3/Q0fqv23IBUJhZKwM1KQRPC1niaVHhqEDBiiX8BvFoOGZBVQUKUOqS0bmfAioGoag58A5vNm0G1on5OX8fJ/3RIPf0Y/nmha7HZR0pequaa4oSNnVFF+Bz8VpIVJYyvE5ni8OmvDc3jii8rWsGcyca3oLwcXDsCpuzANsUPrwYNoff9/lqxbRPBCTvV2OK5IKEXACn5NmtBvGA+WLw/GkYqeIQgAqZy0UPer9HfX0PWPF+oxFXCB61aRMk6q9AAEDinwY8/90c6MlKu9HzXBupZpqosiO788TUgdhasEA5bOmKtbdfR7HUbFu0681mQyOtIzVaHgwTbAVcJD6S/uN/b50s4D1RjvvdAZOVsMK+NGICnAsmJpxxxD395TfvJT1n3Evy9up/oEfbGJHPjSTMH9ZsgDBbjoxvBIGWUGH9INt1Ef0HBuFd8L/KSHdqdLyhJTn6tV+jVQHHOIkHRo+f04b3z1a6x3fMXG7WE1Pk4MZn+bk0YvaO35hp4Ll4LTHZePx0i8+V+VoE2hn8gHdcn93nARAc00hAOW0tdZ/7BrkolARhcO8i/xaL7xoRFWmYchb1XO/92Uq65HxLuFpVhezbWpWbtBBLdNYbt5VdP/M4Ji71hm2D8RxgMc2X59LvRZOpklX6+BRVPqGdaaggMzp48ky7CliSj1nlab+wgproGp9ZaUpwi1KyxDS2j/yS4Cye2rrW4AkhdfdWqHOqn27dtC80PJExXgje0b/fZ1Lm10zjLFT/Que6Y18Acb8Z/B9LPs1KDFSe1Qq6FJ/KgYib63C8zf1sL8kqsRPxRYAcmY1nv33FK8gjsnpGdli/3xixAdaegHyqoctuLw0hHSOuMZkNvJ9UGHKI7CqAvSM3YckgPRef3e70Jw3l46dFxKqRUKoHulyWxHLXFrxiiFyrLY";
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
