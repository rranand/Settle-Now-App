import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow/notification/notification_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/router/router_constant.dart';

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
    final payload = receivedAction.payload ?? {};

    final type = payload["type"]?.toString() ?? "";
    final entityId = payload["entity_id"]?.toString() ?? "";

    if (type != "requestID" || entityId.isEmpty) {
      if (!context.mounted) return;

      NotificationInterfaceHandler.notificationProcessor(
        context,
        Map<String, dynamic>.from(payload),
      );

      return;
    }

    final notificationId = receivedAction.id;
    final channelKey = receivedAction.channelKey;

    if (notificationId == null || channelKey == null) {
      return;
    }

    switch (receivedAction.buttonKeyPressed) {
      case "JOIN":
        await _handleInviteAction(
          context: context,
          receivedAction: receivedAction,
          notificationId: notificationId,
          channelKey: channelKey,
          accept: true,
          entityId: entityId,
        );
        return;

      case "CANCEL":
        await _handleInviteAction(
          context: context,
          receivedAction: receivedAction,
          notificationId: notificationId,
          channelKey: channelKey,
          accept: false,
          entityId: entityId,
        );
        return;

      default:
        if (!context.mounted) return;

        context.push(
          RouterConstants.dashboardRouteName,
          extra: {'initalIndex': 4},
        );
    }
  }

  static Future<void> _handleInviteAction({
    required BuildContext context,
    required ReceivedAction receivedAction,
    required int notificationId,
    required String channelKey,
    required bool accept,
    required String entityId,
  }) async {
    if (!context.mounted) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: channelKey,
        title: receivedAction.title,
        body: receivedAction.body,
        notificationLayout: NotificationLayout.ProgressBar,
        progress: 50,
      ),
    );

    if (!context.mounted) return;

    try {
      final repository = context.read<NotificationRepository>();

      if (accept) {
        await repository.acceptInvite(entityId);
      } else {
        await repository.declineInvite(entityId);
      }

      await AwesomeNotifications().dismiss(notificationId);
    } catch (error) {
      // Restore the notification if the action fails.
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: channelKey,
          title: receivedAction.title,
          body: receivedAction.body,
          payload: receivedAction.payload,
        ),
      );

      rethrow;
    }
  }
}
