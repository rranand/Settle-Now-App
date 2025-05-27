import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

Future<String> generateFCMToken() async {
  if (kIsWeb) {
    return "web";
  }
  String fcmToken = "NoTokenGenerated";
  try {
    final FirebaseMessaging fcm = FirebaseMessaging.instance;
    final token = await fcm.getToken();
    fcmToken = token.toString();

    return fcmToken;
  } catch (_) {
    rethrow;
  }
}
