import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/provider/theme_provider.dart';
import 'package:settlenow_v2/router/router_config.dart';
import 'package:settlenow_v2/theme/themes.dart';
import 'firebase/firebase_options.dart' as firebase_prod;
import 'firebase/firebase_options_dev.dart' as firebase_dev;

// TODO : Dashboard - QuickSplit
// TODO : Dashboard - Room
// TODO : Dashboard - CRUD QuickSplit
// TODO : Dashboard - Create Room
// TODO : Dashboard - Join Room
// TODO : Room - CRUD Expense
// TODO : Room - Create Room
// TODO : Room - Join Room
// TODO : Notification - Send/Receive
// TODO : Personal Expense - Dashboard
// TODO : Personal Expense - Monthly
// TODO : Personal Expense - CRUD Expense
// TODO : Len-Den - Dashboard
// TODO : Len-Den - Create Join Room
// TODO : Len-Den - CRUD Expense
// TODO : Profile Page - Show Info / Login Info
// TODO : Bank Transaction - Expense
// TODO : Bank Transaction - Add Expense To
// TODO : Analysis Page
// TODO : Join Room via Deeplink
// FIXME: On Screen Size Change Notifier is not working

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage remoteMessage,
) async {}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;

  String firebaseProjectName = '[DEFAULT]';
  if (kDebugMode) {
    firebaseProjectName = 'settlenow-dev';
  }
  if (kIsWeb) {
    await Firebase.initializeApp(
      options:
          kDebugMode
              ? firebase_dev.DefaultFirebaseOptions.currentPlatform
              : firebase_prod.DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp(
      name: firebaseProjectName,
      options:
          kDebugMode
              ? firebase_dev.DefaultFirebaseOptions.currentPlatform
              : firebase_prod.DefaultFirebaseOptions.currentPlatform,
    );
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    DevicePreview(
      enabled: !kReleaseMode && kIsWeb,
      builder: (context) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ScreenSizeProvider>(
          create: (_) => ScreenSizeProvider(),
        ),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ],
      builder: (context, _) {
        context.read<ScreenSizeProvider>().calculatePadding(
          MediaQuery.of(context).size.width,
        );
        ThemeProvider themeProvider = context.watch<ThemeProvider>();

        return MaterialApp.router(
          routerConfig: AppRouterConfig.router(context),
          title: 'Settle Now',
          themeMode:
              themeProvider.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
          theme: CustomTheme.lightTheme(context),
          darkTheme: CustomTheme.darkTheme(context),
          locale: Locale('en', 'IN'),
          supportedLocales: [Locale('en', 'IN')],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
        );
      },
    );
    // return MultiRepositoryProvider(
    //   providers: [],
    //   child: MultiBlocProvider(
    //     providers: [],
    //     child: MultiProvider(
    //       providers: [
    //         ChangeNotifierProvider<ScreenSizeProvider>(
    //           create: (_) => ScreenSizeProvider(),
    //         ),
    //       ],
    //       builder: (context, _) {
    //         context.read<ScreenSizeProvider>().calculatePadding(
    //           MediaQuery.of(context).size.width,
    //         );

    //         return MaterialApp.router(
    //           routerConfig: AppRouterConfig.router(context),
    //           title: 'Settle Now',
    //           locale: DevicePreview.locale(context),
    //           builder: DevicePreview.appBuilder,
    //           theme: ThemeData(
    //             colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    //             useMaterial3: true,
    //           ),
    //         );
    //       },
    //     ),
    //   ),
    // );
  }
}
