import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

Future<void> initializeChannels() async {
  await AwesomeNotifications()
      .initialize('resource://drawable/ic_notification_icon', [
    NotificationChannel(
        channelKey: "roomID",
        channelName: "Room",
        channelDescription: 'Notification channel for Room',
        defaultColor: Colors.white),
    NotificationChannel(
        channelKey: "lendenID",
        channelName: "Len-Den",
        channelDescription: 'Notification channel for Len-Den',
        defaultColor: Colors.white),
    NotificationChannel(
        channelKey: "requestID",
        channelName: "Room Request",
        channelDescription: 'Notification channel for Room Request',
        defaultColor: Colors.white),
    NotificationChannel(
        channelKey: "reminderID",
        channelName: "Reminder",
        channelDescription: 'Notification channel for Reminders',
        defaultColor: Colors.white),
    NotificationChannel(
        channelKey: "accountID",
        channelName: "Account",
        channelDescription: 'Notification channel for Account',
        defaultColor: Colors.white),
    NotificationChannel(
        channelKey: "miscellaneousID",
        channelName: "Miscellaneous",
        channelDescription: 'Notification channel for Miscellaneous',
        defaultColor: Colors.white),
    NotificationChannel(
        channelKey: "quickSplitID",
        channelName: "Quick Split",
        channelDescription: 'Notification channel for Quick Split',
        defaultColor: Colors.white),
  ]);
}
