import 'package:encrypt/encrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class crypto {
  static final _key = Key.fromUtf8(dotenv.get("crypto_key"));
  static final _iv = IV.fromUtf8(dotenv.get('crypto_iv'));

  static final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));

  static String encrypt(String Text) {
    final encrypted = encrypter.encrypt(Text, iv: _iv);
    return encrypted.base64;
  }

  static String decrypt(String Text) {
    final decrypted = encrypter.decrypt64(Text, iv: _iv);

    return decrypted;
  }
}
