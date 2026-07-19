import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleOauth {
  static final _googleSignIn = GoogleSignIn.instance;
  static bool _isGoogleSignInInitialized = false;

  static Future<void> _initializeGoogleSignIn() async {
    if (_isGoogleSignInInitialized) {
      return;
    }

    try {
      await _googleSignIn.initialize(
        clientId:
            kIsWeb
                ? "950526449356-doog0pf9reuu509ojduglv8dogllanl2.apps.googleusercontent.com"
                : null,
      );

      _isGoogleSignInInitialized = true;
    } catch (_) {}
  }

  static Future<GoogleSignInAccount> login() =>
      _googleSignIn.authenticate(scopeHint: ['email']);

  static Future<void> logout() => _googleSignIn.signOut();

  static GoogleSignIn getInstance() => _googleSignIn;

  static Future<void> ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _initializeGoogleSignIn();
    }
  }
}
