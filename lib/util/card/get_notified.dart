import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:settlenow/provider/provider_core.dart';
import 'package:settlenow/util/util_core.dart';

class GetNotified extends StatefulWidget {
  const GetNotified({super.key});

  @override
  State<GetNotified> createState() => _GetNotifiedState();
}

class _GetNotifiedState extends State<GetNotified> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;

  Future<void> initialization() async {
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Get Notified"),
        titleSpacing: _mainScreenPadding.left,
        leading: appBarBackButton(context),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: _mainScreenPadding.add(const EdgeInsets.all(15.0)),
          child: Column(
            children: [
              const Spacer(flex: 2),

              Image.asset(
                'assets/Images/notifications.png',
                height: 150,
                width: 150,
              ),

              const SizedBox(height: 32),

              Text(
                'Stay up to date',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Get notified about expenses, payments and group activity.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 3),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () async {
                    final isAllowed =
                        await AwesomeNotifications().isNotificationAllowed();

                    if (!isAllowed) {
                      await getNotificationPermission();
                    }

                    if (context.mounted) {
                      context.pop(true);
                    }
                  },
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Enable Notifications',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 46,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      side: BorderSide(
                        color: theme.primaryColor.withAlpha(100),
                        width: 1.0,
                      ),
                    ),
                    onPressed: () async {
                      context.pop(false);
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
