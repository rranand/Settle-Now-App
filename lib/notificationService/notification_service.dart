import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/others/route_service.dart';
import 'package:settlenow/screens/rooms.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    );

    notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      Map<String, String> data = await getDataFromNotification(payload);

      if (data.isNotEmpty) {
        NavKey.navKey.currentState!.push(MaterialPageRoute(
            builder: (_) => RoomExpense(
                roomKey: data["roomKey"]!,
                email: data["email"]!,
                roomName: data["roomName"]!,
                token: data["token"]!,
                roomLink: data["roomLink"]!,
                isRoomActive:
                    ((data["isRoomActive"]!) == 'true' ? true : false))));
      }
    });
  }

  static void createanddisplaynotification(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "roomID",
          "Room",
          importance: Importance.max,
          priority: Priority.high,
        ),
      );

      await notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: message.data.toString(),
      );
    } on Exception catch (_) {}
  }

  static void createanddisplaynotificationAll(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "allNotifications",
          "Miscellaneous",
          importance: Importance.max,
          priority: Priority.high,
        ),
      );

      await notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: message.data['_id'],
      );
    } on Exception catch (_) {}
  }
}
