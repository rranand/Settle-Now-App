import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/routes/route_constant.dart';
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
      if (receivedAction.buttonKeyPressed == "JOIN" ||
          receivedAction.buttonKeyPressed == "CANCEL") {
        String confirm = "0";
        if (receivedAction.buttonKeyPressed == "JOIN") {
          confirm = "1";
        }
        Map<String, dynamic> jsonInputData = {
          'roomKey': crypto.encrypt(receivedAction.payload!["key"].toString()),
          'email': crypto.encrypt(receivedAction.payload!["email"].toString()),
          'id': crypto.encrypt(receivedAction.payload!["requestID"].toString()),
          'confirm': crypto.encrypt(confirm)
        };

        await createHTTPreq(
            'friend',
            http.put,
            receivedAction.payload!["token"].toString(),
            jsonInputData,
            context);
      } else {
        context.push(AppRouteConstants.dashboardRouteName,
            extra: {'dash': 1, 'firstTime': false});
      }
    } else if (receivedAction.payload!["type"] == "LenDenRequest") {
      if (receivedAction.buttonKeyPressed == "JOIN" ||
          receivedAction.buttonKeyPressed == "CANCEL") {
        String confirm = "0";
        if (receivedAction.buttonKeyPressed == "JOIN") {
          confirm = "1";
        }
        Map<String, dynamic> jsonInputData = {
          'id': crypto.encrypt(receivedAction.payload!["key"].toString()),
          'email': crypto.encrypt(receivedAction.payload!["email"].toString()),
          'id': crypto.encrypt(receivedAction.payload!["requestID"].toString()),
          'confirm': crypto.encrypt(confirm)
        };

        await createHTTPreq(
            'friend/lend',
            http.put,
            receivedAction.payload!["token"].toString(),
            jsonInputData,
            context);
      } else {
        context.push(AppRouteConstants.dashboardRouteName,
            extra: {'dash': 1, 'firstTime': false});
      }
    } else if (receivedAction.payload!["type"] == "room" ||
        receivedAction.payload!["type"] == "lend") {
      if ((receivedAction.payload!["type"]!) == "room") {
        context.push(AppRouteConstants.roomRouteName +
            "/" +
            receivedAction.payload!["roomKey"]!);
      } else {
        context.push(AppRouteConstants.lendByTitleRouteName +
            "/" +
            receivedAction.payload!["roomKey"]!);
      }
    } else if (receivedAction.payload!["type"] == "account") {
      context.push(AppRouteConstants.profileRouteName);
    } else if (receivedAction.payload!["type"] == "quickSplit") {
      context.push(AppRouteConstants.dashboardRouteName,
          extra: {'dash': 0, 'firstTime': false});
    } else if (receivedAction.payload!["type"] == "reminder") {
      context.push(AppRouteConstants.schduleNotificationRouteName);
    } else {
      context.push(AppRouteConstants.dashboardRouteName,
          extra: {'dash': 0, 'firstTime': false});
    }
  }
}
