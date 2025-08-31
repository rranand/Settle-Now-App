import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow_v2/notification/notification_controller.dart';
import 'package:settlenow_v2/router/router_constant.dart';

class NotificationInterfaceHandler {
  static Future<void> initateListeners(BuildContext context) async {
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) async {
        NotificationController.onActionReceivedMethod(context, receivedAction);
      },
      onNotificationCreatedMethod: (
        ReceivedNotification receivedNotification,
      ) async {
        NotificationController.onNotificationCreatedMethod(
          receivedNotification,
        );
      },
      onNotificationDisplayedMethod: (
        ReceivedNotification receivedNotification,
      ) async {
        NotificationController.onNotificationDisplayedMethod(
          receivedNotification,
        );
      },
      onDismissActionReceivedMethod: (ReceivedAction receivedAction) async {
        NotificationController.onDismissActionReceivedMethod(receivedAction);
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
            channelName: "Quick Split",
            channelDescription: 'Notification channel for Quick Split',
            defaultColor: Colors.white,
          ),
        ]);
  }

  static void notificationProcessor(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    if (!kIsWeb) {
      switch (data["type"]) {
        case "room":
          {
            context.go("${RouterConstants.roomRouteName}/${data["id"]!}");
            break;
          }
        case "lenden":
          {
            context.go("${RouterConstants.lendenRouteName}/${data["id"]!}");
            break;
          }
        case "account":
          {
            context.push(RouterConstants.dashboardRouteName);
            break;
          }
        case "quicksplit":
          {
            context.push(
              RouterConstants.dashboardRouteName,
              extra: {'initalIndex': 1},
            );
            break;
          }
        case "roomRequest" || "lendenRequest":
          {
            context.push(
              RouterConstants.dashboardRouteName,
              extra: {'initalIndex': 4},
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
  }

  static void fcmConfiguration(
    BuildContext context,
    bool isNotificationAllowed,
  ) async {
    if (isNotificationAllowed) {
      FirebaseMessaging.instance.getInitialMessage().then((message) async {
        if (message != null && context.mounted) {
          notificationProcessor(context, message.data);
        }
      });

      FirebaseMessaging.onMessage.listen((message) async {
        if (message.notification != null) {
          createNotification(message);
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) async {
        if (context.mounted) {
          notificationProcessor(context, message.data);
        }
      });
    }
  }

  static String getChannelKey(String notificationType) {
    switch (notificationType) {
      case "room":
        {
          return 'roomID';
        }
      case "lenden":
        {
          return 'lendenID';
        }
      case "account":
        {
          return 'accountID';
        }
      case "quicksplit":
        {
          return 'quicksplitID';
        }
      case "roomRequest" || "lendenRequest":
        {
          return 'requestID';
        }
      default:
        {
          return 'miscellaneousID';
        }
    }
  }

  static void createNotification(RemoteMessage message) async {
    if (!kIsWeb) {
      Map<String, String> data = message.data.map(
        (key, value) => MapEntry(key, value.toString()),
      );

      String channelKey = getChannelKey(data['type'] ?? "");

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: -1,
          channelKey: channelKey,
          title: message.notification!.title,
          body: message.notification!.body,
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
}
