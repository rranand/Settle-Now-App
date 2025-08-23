import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow_v2/notification/notification_interface_handler.dart';
import 'package:settlenow_v2/data/repository/notification_repository.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/handler/local_storage_preference.dart';

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    BuildContext context,
    ReceivedAction receivedAction,
  ) async {
    String type = receivedAction.payload!["type"] ?? "";
    String id = receivedAction.payload!["id"] ?? "";

    if (id.isNotEmpty && (type == "roomRequest" || type == "lendenRequest")) {
      String? authToken = await LocalStoragePreference.getStringPref(
        'auth_token',
      );

      switch (receivedAction.buttonKeyPressed) {
        case "JOIN":
          {
            if (context.mounted) {
              AwesomeNotifications().createNotification(
                content: NotificationContent(
                  id: receivedAction.id!,
                  channelKey: receivedAction.channelKey!,
                  title: receivedAction.title,
                  body: receivedAction.body,
                  notificationLayout: NotificationLayout.ProgressBar,
                  progress: 50,
                ),
              );
              await context.read<NotificationRepository>().acceptInvite(
                id,
                authToken ?? "",
              );
              await AwesomeNotifications().dismiss(receivedAction.id!);
            }
          }
        case "CANCEL":
          {
            if (context.mounted) {
              AwesomeNotifications().createNotification(
                content: NotificationContent(
                  id: receivedAction.id!,
                  channelKey: receivedAction.channelKey!,
                  title: receivedAction.title,
                  body: receivedAction.body,
                  notificationLayout: NotificationLayout.ProgressBar,
                  progress: 50,
                ),
              );
              await context.read<NotificationRepository>().declineInvite(
                id,
                authToken ?? "",
              );
              await AwesomeNotifications().dismiss(receivedAction.id!);
            }
          }
        default:
          {
            context.push(
              RouterConstants.dashboardRouteName,
              extra: {'initalIndex': 4},
            );
          }
      }
    } else {
      Map<String, dynamic> data = {};
      data["type"] = type;
      data["id"] = id;

      NotificationInterfaceHandler.notificationProcessor(context, data);
    }
  }
}
