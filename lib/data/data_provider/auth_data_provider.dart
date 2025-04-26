import 'package:settlenow_v2/model/user_model.dart';

class AuthDataProvider {
  Future<String> loginUser(String username, String password) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      UserModel userData = UserModel.fromBasicInfo(
        name: 'Rohit Anand',
        id: 'rranand',
        profileImage: "https://picsum.photos/id/5/200/300",
      );

      return userData.toJson();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> signUpUser(String name, String email) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});

      return true;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> sendOTP(String email) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});

      return true;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> logoutUser(String uid, String sessionToken) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});

      return true;
    } catch (e) {
      throw e.toString();
    }
  }
}
