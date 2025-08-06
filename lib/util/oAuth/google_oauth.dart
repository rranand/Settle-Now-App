import 'package:google_sign_in/google_sign_in.dart';

class GoogleOauth {
  static final _googleSignIn = GoogleSignIn();

  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();

  static Future<void> logout() async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {}
  }
}
