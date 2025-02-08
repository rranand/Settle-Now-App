import 'package:encrypt/encrypt.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import '../contents.dart' as global;

class crypto {
  static final _key = Key.fromUtf8(global.crypto_key);
  static final _iv = IV.fromUtf8(global.crypto_iv);

  static final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));

  static String encrypt(String text) {
    try {
      final encrypted = encrypter.encrypt(text, iv: _iv);
      return encrypted.base64;
    } on Exception catch (err, stackTrace) {
      onException(err, stackTrace,
          reason: "Unknwon Error", info: ["Crypto->encrypt"]);
    } finally {
      return "";
    }
  }

  static String decrypt(String text) {
    final decrypted = encrypter.decrypt64(text, iv: _iv);

    return decrypted;
  }
}
