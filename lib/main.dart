import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  AwesomeNotifications().initialize(null, [
    NotificationChannel(
        channelKey: "roomID",
        channelName: "Room",
        channelDescription: 'Notification channel for Room',
        defaultColor: Colors.deepPurple),
    NotificationChannel(
        channelKey: "lendenID",
        channelName: "Len-Den",
        channelDescription: 'Notification channel for Len-Den',
        defaultColor: Colors.deepPurple),
    NotificationChannel(
        channelKey: "requestID",
        channelName: "Room Request",
        channelDescription: 'Notification channel for Room Request',
        defaultColor: Colors.deepPurple),
    NotificationChannel(
        channelKey: "remainderID",
        channelName: "Remainder",
        channelDescription: 'Notification channel for Remainders',
        defaultColor: Colors.deepPurple),
  ]);

  runApp(MyApp());
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
