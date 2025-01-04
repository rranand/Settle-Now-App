import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/sharedPrefParse.dart';
import 'package:settlenow/others/themes.dart';
import 'package:settlenow/routes/route_constant.dart';

class NotificationPermission extends StatefulWidget {
  final bool firstTime;
  const NotificationPermission({Key? key, required this.firstTime})
      : super(key: key);

  @override
  State<NotificationPermission> createState() => _NotificationPermissionState();
}

class _NotificationPermissionState extends State<NotificationPermission> {
  bool notificationPermissionGranted = false;

  initialization() async {
    setBoolPrefs('isNotificationPremissionPoppedProvided', true);
    var tokenData = await getStringPref('token');

    if (tokenData == null) {
      while (this.mounted && context.canPop()) {
        context.pop();
      }
      if (this.mounted) {
        context.go(AppRouteConstants.loginRouteName);
      }
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    initialization();
  }

  Future<void> getNotificationPermission() async {
    bool permissionGranted =
        await AwesomeNotifications().isNotificationAllowed();

    var flags = await Future.wait([
      Permission.accessNotificationPolicy.isDenied,
      Permission.accessNotificationPolicy.isPermanentlyDenied
    ]);

    permissionGranted = flags[0] || flags[1];
    permissionGranted = !permissionGranted;

    if (!permissionGranted) {
      permissionGranted =
          await AwesomeNotifications().requestPermissionToSendNotifications();
      flags = await Future.wait([
        Permission.accessNotificationPolicy.isDenied,
        Permission.accessNotificationPolicy.isPermanentlyDenied
      ]);

      permissionGranted = flags[0] || flags[1];
      permissionGranted = !permissionGranted;
    }

    if (permissionGranted) {
      notificationPermissionGranted = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: !widget.firstTime,
          title: Text(
            "Get Notified",
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
      body: PopScope(
        canPop: false,
        onPopInvoked: ((didPop) {
          if (didPop) {
            return;
          }
          context.pop(notificationPermissionGranted);
        }),
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/Images/notifications.png',
                      height: 150,
                      width: 150,
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Text(
                    "To enhance your experience with Settle Now, we’d like to send you notifications to keep you updated on bill splits, reminders for pending payments, and updates from your groups. These notifications ensure you never miss an important activity and stay in sync with your friends or flatmates. Enable push notifications to make settling expenses smoother and hassle-free!",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 29,
                  ),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 46,
                      child: OutlinedButton(
                        child: Text(
                          "Give Permission",
                          style: TextStyle(
                              color: themeProvider.isDarkTheme
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 16),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          side:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        onPressed: () async {
                          bool isPermanent = await AwesomeNotifications()
                              .isNotificationAllowed();
                          if (isPermanent) {
                            openAppSettings();
                          } else {
                            await getNotificationPermission();
                          }
                          if (this.mounted) {
                            context.pop(
                                notificationPermissionGranted || isPermanent);
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 46,
                      child: OutlinedButton(
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                              color: themeProvider.isDarkTheme
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 16),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          side: BorderSide(color: Colors.redAccent),
                        ),
                        onPressed: () async {
                          context.pop(false);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
