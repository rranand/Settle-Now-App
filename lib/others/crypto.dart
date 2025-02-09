import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import '../contents.dart' as global;

class crypto {
  static final Key _key =
      Key(utf8.encode(global.crypto_key)); // 32-byte key for AES-256
  static final IV _iv =
      IV(utf8.encode(global.crypto_iv)); // 16-byte IV for CBC mode

  static String encrypt(String text) {
    final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(text, iv: _iv);
    return encrypted.base64;
  }

  static String decrypt(String text) {
    final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
    final decrypted = encrypter.decrypt64(text, iv: _iv);
    return decrypted;
  }
}
