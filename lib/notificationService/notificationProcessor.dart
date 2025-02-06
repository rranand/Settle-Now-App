import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/others/crypto.dart';

Future<void> notificationProcessor(message) async {
  final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  String notificationFrom = "";

  if (message.data.isNotEmpty) {
    notificationFrom = crypto.decrypt(message.data["type"]);
  }

  if (notificationFrom == "room") {
    Map<String, String> notificationData =
        await getDataFromNotification(message.data.toString());
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: id,
            channelKey: 'roomID',
            title: message.notification!.title,
            body: message.notification!.body,
            payload: notificationData));
  } else if (notificationFrom == "lend") {
    Map<String, String> notificationData =
        await getDataFromNotification(message.data.toString());
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: id,
            channelKey: 'lendenID',
            title: message.notification!.title,
            body: message.notification!.body,
            payload: notificationData));
  } else if (notificationFrom == "account") {
    Map<String, String> notificationData =
        await getDataFromNotification(message.data.toString());
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: id,
            channelKey: 'accountID',
            title: message.notification!.title,
            body: message.notification!.body,
            payload: notificationData));
  } else if (notificationFrom == "RoomRequest" ||
      notificationFrom == "LenDenRequest") {
    Map<String, String> notificationData =
        await getDataFromNotification(message.data.toString());
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: id,
            channelKey: 'requestID',
            title: message.notification!.title,
            body: message.notification!.body,
            payload: notificationData),
        actionButtons: [
          NotificationActionButton(key: 'JOIN', label: 'Join'),
          NotificationActionButton(key: 'CANCEL', label: 'Cancel'),
        ]);
  } else if (notificationFrom == "quickSplit") {
    Map<String, String> notificationData =
        await getDataFromNotification(message.data.toString());
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: id,
            channelKey: 'quickSplitID',
            title: message.notification!.title,
            body: message.notification!.body,
            payload: notificationData));
  } else {
    Map<String, String> notificationData =
        await getDataFromNotification(message.data.toString());
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: id,
            channelKey: 'miscellaneousID',
            title: message.notification!.title,
            body: message.notification!.body,
            payload: notificationData));
  }
}
