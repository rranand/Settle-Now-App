import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:settlenow_v2/util/functions/text_function.dart';

Future<Map<String, String>> platformState() async {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  try {
    if (kIsWeb) {
      WebBrowserInfo data = await deviceInfoPlugin.webBrowserInfo;
      return <String, String>{
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'device':
            "${capatilizeFirstLetter(data.browserName.name)} (${data.platform!})",
        'userAgent': data.userAgent!,
      };
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo build = await deviceInfoPlugin.androidInfo;
      return <String, String>{
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'device':
            "${build.model} (Android ${build.version.release}, ${build.device})",
        'userAgent': "Unknown",
      };
    }
  } catch (_) {}

  return <String, String>{'id': 'Not Found', 'device': 'Not Found'};
}

Future<String> fetchIP({int attempt = 0}) async {
  if (attempt == 5) {
    return "Unknown";
  }
  try {
    final ipAddressReq = await http.get(Uri.parse('https://api64.ipify.org'));

    if (ipAddressReq.statusCode == 200) {
      return ipAddressReq.body;
    } else {
      throw "Unable to Fetch IP";
    }
  } on Exception catch (_) {
    fetchIP(attempt: attempt + 1);
  }

  return "Unknown";
}
