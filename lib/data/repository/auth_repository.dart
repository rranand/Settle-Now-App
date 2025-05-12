import 'dart:convert';

import 'package:settlenow_v2/data/data_provider/auth_data_provider.dart';
import 'package:settlenow_v2/model/user_model.dart';

class AuthRepository {
  final AuthDataProvider _dataProvider;
  AuthRepository(this._dataProvider);

  Future<UserModel> getLoggedInUser() async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      UserModel userData = UserModel.fromBasicInfo(
        name: 'Rohit Anand',
        id: 'user_1',
        profileImage: "https://picsum.photos/id/5/200/300",
      );
      userData.email = "rrohitanand3336@gmail.com";
      return userData;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel> getLoginToken(String email, String otp) async {
    try {
      final loginData = await _dataProvider.loginUser(email, otp);
      final data = jsonDecode(loginData);
      return UserModel.fromMap(data);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> signUpUser(String name, String email) async {
    try {
      final isSignUpSuccessful = await _dataProvider.signUpUser(name, email);

      return isSignUpSuccessful;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> sendOTP(String email) async {
    try {
      final isOTPSend = await _dataProvider.sendOTP(email);
      return isOTPSend;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> logoutUser(String uid, String sessionToken) async {
    try {
      final isLogoutSuccessful = await _dataProvider.logoutUser(
        uid,
        sessionToken,
      );
      return isLogoutSuccessful;
    } catch (e) {
      throw e.toString();
    }
  }
}
