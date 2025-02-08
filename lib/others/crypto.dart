import 'package:encrypt/encrypt.dart';
import '../contents.dart' as global;

class crypto {
  static final _key = Key.fromUtf8(global.crypto_key);
  static final _iv = IV.fromUtf8(global.crypto_iv);

  static final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));

  static String encrypt(String text) {
    final encrypted = encrypter.encrypt(text, iv: _iv);
    return encrypted.base64;
  }

  static String decrypt(String text) {
    final decrypted = encrypter.decrypt64(text, iv: _iv);
    return decrypted;
  }
}
