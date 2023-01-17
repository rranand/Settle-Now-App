import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/others/crypto.dart';
import 'package:settlenow/others/route_service.dart';
import 'package:settlenow/screens/lendPage.dart';
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
            builder: (_) => (data["type"]!) == "room"
                ? RoomExpense(
                    roomKey: data["roomKey"]!,
                    email: data["email"]!,
                    roomName: data["roomName"]!,
                    token: data["token"]!,
                    roomLink: data["roomLink"]!,
                    isRoomActive:
                        ((data["isRoomActive"]!) == 'true' ? true : false))
                : LendPage(
                    email: data["email"]!,
                    token: data["token"]!,
                    name: data["roomName"]!,
                    roomkey: data["key"]!,
                    roomLink: data["roomLink"]!)));
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

      const NotificationDetails notificationDetailsLenDen = NotificationDetails(
        android: AndroidNotificationDetails(
          "lendenID",
          "Len-Den",
          importance: Importance.max,
          priority: Priority.high,
        ),
      );

      const NotificationDetails notificationDetailsOther = NotificationDetails(
        android: AndroidNotificationDetails(
          "requestID",
          "Room Request",
          importance: Importance.max,
          priority: Priority.high,
        ),
      );
      String notificationFrom = "";

      if (message.data.isNotEmpty) {
        notificationFrom = crypto.decrypt(message.data["type"]);
      }

      if (notificationFrom == "room") {
        await notificationsPlugin.show(
          id,
          message.notification!.title,
          message.notification!.body,
          notificationDetails,
          payload: message.data.toString(),
        );
      } else if (notificationFrom == "lend") {
        await notificationsPlugin.show(
          id,
          message.notification!.title,
          message.notification!.body,
          notificationDetailsLenDen,
          payload: message.data.toString(),
        );
      } else {
        await notificationsPlugin.show(
          id,
          message.notification!.title,
          message.notification!.body,
          notificationDetailsOther,
          payload: message.data.toString(),
        );
      }
    } on Exception catch (_) {}
  }
}
