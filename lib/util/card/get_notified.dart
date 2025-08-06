import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class GetNotified extends StatefulWidget {
  const GetNotified({super.key});

  @override
  State<GetNotified> createState() => _GetNotifiedState();
}

class _GetNotifiedState extends State<GetNotified> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;

  initialization() async {
    bool isPermanent = await AwesomeNotifications().isNotificationAllowed();

    if (isPermanent && mounted) {
      context.pop(isPermanent);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainScreenPadding = context.watch<ScreenSizeProvider>().getPadding;

    if (mounted) {
      setState(() {});
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
      Permission.accessNotificationPolicy.isPermanentlyDenied,
    ]);

    permissionGranted = !(flags[0] || flags[1]);

    if (!permissionGranted) {
      permissionGranted =
          await AwesomeNotifications().requestPermissionToSendNotifications();
      flags = await Future.wait([
        Permission.accessNotificationPolicy.isDenied,
        Permission.accessNotificationPolicy.isPermanentlyDenied,
      ]);

      permissionGranted = flags[0] || flags[1];
      permissionGranted = !permissionGranted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Get Notified"),
        titleSpacing: _mainScreenPadding.left,
        leading: appBarBackButton(context),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: _mainScreenPadding.add(EdgeInsets.all(15.0)),
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
            SizedBox(height: 24),
            Text(
              "To enhance your experience with Settle Now, we’d like to send you notifications to keep you updated on bill splits, reminders for pending payments, and updates from your groups. These notifications ensure you never miss an important activity and stay in sync with your friends or flatmates. Enable push notifications to make settling expenses smoother and hassle-free!",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 29),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 46,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  onPressed: () async {
                    bool isPermanent =
                        await AwesomeNotifications().isNotificationAllowed();
                    if (!isPermanent) {
                      await getNotificationPermission();
                    }
                    if (context.mounted) {
                      context.pop(true);
                    }
                  },
                  child: Text(
                    "Give Permission",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 46,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    side: BorderSide(color: Colors.redAccent),
                  ),
                  onPressed: () async {
                    context.pop(false);
                  },
                  child: Text("Cancel", style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
