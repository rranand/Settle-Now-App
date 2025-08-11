import 'package:google_sign_in/google_sign_in.dart';

class GoogleOauth {
  static final _googleSignIn = GoogleSignIn.instance;
  static bool _isGoogleSignInInitialized = false;

  GoogleOauth() {
    _initializeGoogleSignIn();
  }

  static Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;
    } catch (_) {}
  }

  static Future<GoogleSignInAccount> login() =>
      _googleSignIn.authenticate(scopeHint: ['email']);

  static Future<void> logout() => _googleSignIn.signOut();

  static Future<void> ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _initializeGoogleSignIn();
    }
  }
}
