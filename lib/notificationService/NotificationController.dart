import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:settlenow/others/route_service.dart';
import 'package:settlenow/screens/lendPage.dart';
import 'package:settlenow/screens/rooms.dart';
import '../contents.dart' as global;
import 'package:settlenow/others/crypto.dart';

class NotificationController {
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {}

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {}

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {}

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.payload!["type"] == "RoomRequest") {
      if (receivedAction.buttonKeyPressed == "JOIN") {
        await http.put(Uri.parse(global.url + 'friend'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Auth': receivedAction.payload!["token"].toString()
            },
            body: jsonEncode({
              'roomKey':
                  crypto.encrypt(receivedAction.payload!["key"].toString()),
              'email':
                  crypto.encrypt(receivedAction.payload!["email"].toString()),
              'confirm': crypto.encrypt("1")
            }));
      } else {
        await http.put(Uri.parse(global.url + 'friend'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Auth': receivedAction.payload!["token"].toString()
            },
            body: jsonEncode({
              'roomKey':
                  crypto.encrypt(receivedAction.payload!["key"].toString()),
              'email':
                  crypto.encrypt(receivedAction.payload!["email"].toString()),
              'confirm': crypto.encrypt("0")
            }));
      }
    } else if (receivedAction.payload!["type"] == "LenDenRequest") {
      if (receivedAction.buttonKeyPressed == "JOIN") {
        await http.put(Uri.parse(global.url + 'friend/lend'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Auth': receivedAction.payload!["token"].toString()
            },
            body: jsonEncode({
              'id': crypto.encrypt(receivedAction.payload!["key"].toString()),
              'email': crypto.encrypt(
                  crypto.encrypt(receivedAction.payload!["email"].toString())),
              'confirm': crypto.encrypt("1")
            }));
      } else {
        await http.put(Uri.parse(global.url + 'friend/lend'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Auth': receivedAction.payload!["token"].toString()
            },
            body: jsonEncode({
              'id': crypto.encrypt(receivedAction.payload!["key"].toString()),
              'email': crypto.encrypt(
                  crypto.encrypt(receivedAction.payload!["email"].toString())),
              'confirm': crypto.encrypt("0")
            }));
      }
    } else {
      NavKey.navKey.currentState!.push(MaterialPageRoute(
          builder: (_) => (receivedAction.payload!["type"]!) == "room"
              ? RoomExpense(
                  roomKey: receivedAction.payload!["roomKey"]!,
                  email: receivedAction.payload!["email"]!,
                  roomName: receivedAction.payload!["roomName"]!,
                  token: receivedAction.payload!["token"]!,
                  roomLink: receivedAction.payload!["roomLink"]!,
                  isRoomActive:
                      ((receivedAction.payload!["isRoomActive"]!) == 'true'
                          ? true
                          : false))
              : LendPage(
                  email: receivedAction.payload!["email"]!,
                  token: receivedAction.payload!["token"]!,
                  name: receivedAction.payload!["roomName"]!,
                  roomkey: receivedAction.payload!["key"]!,
                  roomLink: receivedAction.payload!["roomLink"]!)));
    }
  }
}
