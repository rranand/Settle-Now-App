import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/others/route_service.dart';
import 'package:settlenow/screens/dashboard.dart';
import 'package:settlenow/screens/lendPage.dart';
import 'package:settlenow/screens/rooms.dart';
import 'package:settlenow/others/crypto.dart';

class NotificationController {
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      BuildContext context, ReceivedNotification receivedNotification) async {}

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      BuildContext context, ReceivedNotification receivedNotification) async {}

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      BuildContext context, ReceivedAction receivedAction) async {}

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      BuildContext context, ReceivedAction receivedAction) async {
    if (receivedAction.payload!["type"] == "RoomRequest") {
      if (receivedAction.buttonKeyPressed == "JOIN") {
        Map<String, dynamic> jsonInputData = {
          'roomKey': crypto.encrypt(receivedAction.payload!["key"].toString()),
          'email': crypto.encrypt(receivedAction.payload!["email"].toString()),
          'confirm': crypto.encrypt("1")
        };

        await createHTTPreq(
            'friend',
            http.put,
            receivedAction.payload!["token"].toString(),
            jsonInputData,
            context);
      } else if (receivedAction.buttonKeyPressed == "CANCEL") {
        Map<String, dynamic> jsonInputData = {
          'roomKey': crypto.encrypt(receivedAction.payload!["key"].toString()),
          'email': crypto.encrypt(receivedAction.payload!["email"].toString()),
          'confirm': crypto.encrypt("0")
        };

        await createHTTPreq(
            'friend',
            http.put,
            receivedAction.payload!["token"].toString(),
            jsonInputData,
            context);
      } else {
        NavKey.navKey.currentState!.push(MaterialPageRoute(
            builder: (_) => DashBoard(
                  dash: 1,
                  firstTime: false,
                )));
      }
    } else if (receivedAction.payload!["type"] == "LenDenRequest") {
      if (receivedAction.buttonKeyPressed == "JOIN") {
        Map<String, dynamic> jsonInputData = {
          'id': crypto.encrypt(receivedAction.payload!["key"].toString()),
          'email': crypto.encrypt(receivedAction.payload!["email"].toString()),
          'confirm': crypto.encrypt("1")
        };

        await createHTTPreq(
            'friend/lend',
            http.put,
            receivedAction.payload!["token"].toString(),
            jsonInputData,
            context);
      } else if (receivedAction.buttonKeyPressed == "CANCEL") {
        Map<String, dynamic> jsonInputData = {
          'id': crypto.encrypt(receivedAction.payload!["key"].toString()),
          'email': crypto.encrypt(receivedAction.payload!["email"].toString()),
          'confirm': crypto.encrypt("0")
        };

        await createHTTPreq(
            'friend/lend',
            http.put,
            receivedAction.payload!["token"].toString(),
            jsonInputData,
            context);
      } else {
        NavKey.navKey.currentState!.push(MaterialPageRoute(
            builder: (_) => DashBoard(
                  dash: 1,
                  firstTime: false,
                )));
      }
    } else if (receivedAction.payload!["type"] == "room" ||
        receivedAction.payload!["type"] == "lend") {
      NavKey.navKey.currentState!.push(MaterialPageRoute(
          builder: (_) => ((receivedAction.payload!["type"]!) == "room"
              ? RoomExpense(
                  roomKey: receivedAction.payload!["roomKey"]!,
                )
              : LendPage(
                  roomkey: receivedAction.payload!["roomkey"]!,
                ))));
    } else {
      NavKey.navKey.currentState!.push(MaterialPageRoute(
          builder: (_) => DashBoard(
                dash: 1,
                firstTime: false,
              )));
    }
  }
}
