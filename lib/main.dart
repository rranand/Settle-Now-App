import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/screens/loginPage.dart';
import 'notificationService/notification_service.dart';
import 'others/themes.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler); 
  LocalNotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
    FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, _) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        
        return ChangeNotifierProvider(
          create: (context) => ColorProvider(),
          builder: (context, _) {
            final colorProvider = Provider.of<ColorProvider>(context);
            return  MaterialApp(
              themeMode: themeProvider.darkTheme?ThemeMode.dark:ThemeMode.light,
              theme: MyTheme.lightTheme(context, colorProvider.getPrimaryColor),
              darkTheme: MyTheme.darTheme(context),
              title: "Settle Now",
              home: LoginPage(),
            );
          }
        );
      }
    );
  }
}
