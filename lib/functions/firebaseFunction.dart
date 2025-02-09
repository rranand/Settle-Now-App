import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow/functions/additionalFunction.dart';

Future<String> generateFCMToken() async {
  if (kIsWeb) {
    return "";
  }
  String fcmToken = "NoTokenGenerated";
  try {
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    final token = await _fcm.getToken();
    fcmToken = token.toString();
  } on Exception catch (err, stackTrace) {
    pushCrashDataToFirebase(err, stackTrace,
        reason: err.toString(), info: ["firebaseFunction", "generateFCMToken"]);
  } finally {
    return fcmToken;
  }
}
