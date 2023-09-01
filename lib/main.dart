import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/screens/loginPage.dart';
import 'firebase_options.dart';
import 'others/route_service.dart';
import 'others/themes.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AwesomeNotifications().createNotificationFromJsonData(message.data);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
  ]);

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
          return MaterialApp(
            navigatorKey: NavKey.navKey,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: child!,
              );
            },
            themeMode:
                themeProvider.darkTheme ? ThemeMode.dark : ThemeMode.light,
            theme: MyTheme.lightTheme(context),
            darkTheme: MyTheme.darTheme(context),
            title: "Settle Now",
            home: SafeArea(
              child: LoginPage(),
            ),
            onGenerateRoute: RouteServices.generateRoute,
          );
        });
  }
}
