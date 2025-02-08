import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

Future<String> generateFCMToken() async {
  if (kIsWeb) {
    return "";
  }
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final token = await _fcm.getToken();
  return token.toString();
}
