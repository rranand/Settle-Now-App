import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/routes/route_config.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'firebase_options.dart';
import 'others/themes.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AwesomeNotifications().createNotificationFromJsonData(message.data);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  String firebaseProjectName = '[DEFAULT]';
  if (!kIsWeb && kDebugMode) {
    firebaseProjectName = 'SettleNow-Dev';
  }
  if (kIsWeb || Firebase.apps.length == 0) {
    await Firebase.initializeApp(
        name: firebaseProjectName,
        options: DefaultFirebaseOptions.currentPlatform);
  } else {
    Firebase.app(firebaseProjectName);
  }

  if (kIsWeb) {
    usePathUrlStrategy();
  } else {
    await Permission.notification.isDenied.then((value) {
      if (value) {
        Permission.notification.request();
      }
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    AwesomeNotifications()
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
          channelKey: "remainderID",
          channelName: "Remainder",
          channelDescription: 'Notification channel for Remainders',
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

  if (!kIsWeb) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  runApp(MyApp());
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        builder: (context, _) {
          final themeProvider = Provider.of<ThemeProvider>(context);
          return MaterialApp.router(
            routerConfig: AppRouter.router,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(1.0)),
                child: child!,
              );
            },
            themeMode:
                themeProvider.darkTheme ? ThemeMode.dark : ThemeMode.light,
            theme: MyTheme.lightTheme(context),
            darkTheme: MyTheme.darTheme(context),
            title: "Settle Now",
            scrollBehavior: kIsWeb ? MyCustomScrollBehavior() : null,
          );
        });
  }
}
