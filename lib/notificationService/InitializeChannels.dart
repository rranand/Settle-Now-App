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

Future<void> createScheduledNotification(
    int day, String name, List<int> IDs) async {
  for (int i = 0; i < IDs.length; i++) {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: IDs[i],
            channelKey: 'reminderID',
            title: "Reminder",
            body: name,
            payload: {"type": "reminder"}),
        schedule: NotificationAndroidCrontab.monthly(
            referenceDateTime: DateTime(2017, 9, day, 7 + (i * 4), 0),
            allowWhileIdle: true));
  }
}
