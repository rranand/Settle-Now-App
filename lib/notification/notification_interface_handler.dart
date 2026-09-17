import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow/notification/notification_core.dart';
import 'package:settlenow/router/router_constant.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationInterfaceHandler {
  static Future<void> initateListeners(BuildContext context) async {
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) async {
        await NotificationController.onActionReceivedMethod(
          context,
          receivedAction,
        );
      },
      onNotificationCreatedMethod: (
        ReceivedNotification receivedNotification,
      ) async {
        await NotificationController.onNotificationCreatedMethod(
          receivedNotification,
        );
      },
      onNotificationDisplayedMethod: (
        ReceivedNotification receivedNotification,
      ) async {
        await NotificationController.onNotificationDisplayedMethod(
          receivedNotification,
        );
      },
      onDismissActionReceivedMethod: (ReceivedAction receivedAction) async {
        await NotificationController.onDismissActionReceivedMethod(
          receivedAction,
        );
      },
    );
  }

  static Future<void> initializeChannels() async {
    await AwesomeNotifications()
        .initialize('resource://drawable/ic_notification_icon', [
          NotificationChannel(
            channelKey: "roomID",
            channelName: "Room",
            channelDescription: 'Notification channel for Room',
            defaultColor: Colors.white,
          ),
          NotificationChannel(
            channelKey: "lendenID",
            channelName: "Lenden",
            channelDescription: 'Notification channel for Len-Den',
            defaultColor: Colors.white,
          ),
          NotificationChannel(
            channelKey: "requestID",
            channelName: "Request",
            channelDescription: 'Notification channel for Request',
            defaultColor: Colors.white,
          ),
          NotificationChannel(
            channelKey: "accountID",
            channelName: "Account",
            channelDescription: 'Notification channel for Account',
            defaultColor: Colors.white,
          ),
          NotificationChannel(
            channelKey: "miscellaneousID",
            channelName: "Miscellaneous",
            channelDescription: 'Notification channel for Miscellaneous',
            defaultColor: Colors.white,
          ),
          NotificationChannel(
            channelKey: "quicksplitID",
            channelName: "Quicksplit",
            channelDescription: 'Notification channel for Quicksplit',
            defaultColor: Colors.white,
          ),
        ]);
  }

  static void notificationProcessor(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    if (kIsWeb) {
      return;
    }

    final type = data["type"]?.toString() ?? "";
    final entityId = data["entity_id"]?.toString() ?? "";

    switch (type) {
      case "roomID":
        {
          context.go("${RouterConstants.roomRouteName}/$entityId");
          break;
        }
      case "lendenID":
        {
          context.go("${RouterConstants.lendenRouteName}/$entityId");
          break;
        }
      case "accountID":
        {
          context.push(RouterConstants.dashboardRouteName);
          break;
        }
      case "quicksplitID":
        {
          context.push(
            RouterConstants.dashboardRouteName,
            extra: {'initalIndex': 1},
          );
          break;
        }
      case "requestID":
        {
          context.push(
            RouterConstants.dashboardRouteName,
            extra: {'initalIndex': 4},
          );
          break;
        }
      case "updateID":
        {
          launchUrl(
            Uri.parse(
              "https://play.google.com/store/apps/details?id=com.rohit.settlenow&hl=en_IN",
            ),
            mode: LaunchMode.externalApplication,
          );
          break;
        }
      default:
        {
          context.push(RouterConstants.dashboardRouteName);
          break;
        }
    }
  }

  static Future<void> fcmConfiguration(
    BuildContext context,
    bool isNotificationAllowed,
  ) async {
    if (!isNotificationAllowed) {
      return;
    }

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null && context.mounted) {
      notificationProcessor(context, initialMessage.data);
    }

    FirebaseMessaging.onMessage.listen((message) async {
      if (message.notification != null) {
        await createNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (context.mounted) {
        notificationProcessor(context, message.data);
      }
    });
  }

  static Future<void> createNotification(RemoteMessage message) async {
    if (kIsWeb || message.notification == null) {
      return;
    }

    final data = message.data.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    final channelKey = data['type'] ?? "miscellaneousID";

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: channelKey,
        title: message.notification?.title,
        body: message.notification?.body,
        payload: data,
      ),
      actionButtons:
          channelKey == 'requestID'
              ? [
                NotificationActionButton(
                  key: 'JOIN',
                  label: 'Join',
                  isAuthenticationRequired: true,
                ),
                NotificationActionButton(
                  key: 'CANCEL',
                  label: 'Cancel',
                  isAuthenticationRequired: true,
                ),
              ]
              : null,
    );
  }
}
