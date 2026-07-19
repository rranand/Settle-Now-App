import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/foundation.dart' as foundation;

const String jwtToken =
    "BY#uu4qQiLb^SYcOCsxS@lQxu7TZKRozctbbCwGtN93LccoKVU3f6F0IjiDH#J2GH2N!2t^*UTwQtZmD4S#Fy8w#Y3b6d1gN#SHVYgcKX%s4pxQ@vq4vS%Emd#KRKqkF31EQjuB34x!3IMn@TfSTt7";

class Crypto {
  static Future<String> createJWT(String email, String input) async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    String key = '';
    final jwt = JWT(jsonDecode(input));

    if (foundation.kIsWeb) {
      WebBrowserInfo data = await deviceInfoPlugin.webBrowserInfo;
      key = '${data.browserName.name}###${data.platform!}###$email';
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo build = await deviceInfoPlugin.androidInfo;
      key = '${build.id}###${build.board}###${build.fingerprint}###$email';
    } else if (Platform.isIOS) {
      IosDeviceInfo build = await deviceInfoPlugin.iosInfo;
      key =
          '${build.systemVersion}###${build.model}###${build.identifierForVendor}###$email';
    } else {
      key = '${DateTime.now()}###PLATFORM_NO_DEVICE_FOUND###$email';
    }
    return jwt.sign(SecretKey(key));
  }

  static dynamic parseJWT(String jwToken) {
    try {
      var jwtData = JWT.tryDecode(jwToken);
      if (jwtData == null) {
        return null;
      }
      return jwtData.payload;
    } on Exception catch (_) {
      return null;
    }
  }

  static String createJSONDataTOJWT(dynamic data) {
    final jwt = JWT(data);

    return jwt.sign(
      SecretKey(jwtToken),
      expiresIn: foundation.kDebugMode ? null : Duration(seconds: 100),
    );
  }

  static String extractJSONfromJWT(String data) {
    try {
      final reqData = JWT.verify(data, SecretKey(jwtToken));
      return jsonEncode(reqData.payload);
    } on Exception catch (_) {
      rethrow;
    }
  }
}
