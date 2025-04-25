import 'dart:convert';

import 'package:settlenow_v2/data/data_provider/auth/auth_data_provider.dart';
import 'package:settlenow_v2/model/user_model.dart';

class AuthRepository {
  final AuthDataProvider authDataProvider;
  AuthRepository(this.authDataProvider);

  Future<UserModel> getLoggedInUser() async {
    try {
      return UserModel.fromBasicInfo(
        name: 'Rohit Anand',
        id: 'rranand',
        profileImage: "https://picsum.photos/id/5/200/300",
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel> getLoginToken(String email, String otp) async {
    try {
      final loginData = await authDataProvider.loginUser(email, otp);
      final data = jsonDecode(loginData);
      return UserModel.fromMap(data);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> signUpUser(String name, String email) async {
    try {
      final isSignUpSuccessful = await authDataProvider.signUpUser(name, email);

      return isSignUpSuccessful;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> sendOTP(String email) async {
    try {
      final isOTPSend = await authDataProvider.sendOTP(email);
      return isOTPSend;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> logoutUser(String uid, String sessionToken) async {
    try {
      final isLogoutSuccessful = await authDataProvider.logoutUser(
        uid,
        sessionToken,
      );
      return isLogoutSuccessful;
    } catch (e) {
      throw e.toString();
    }
  }
}
