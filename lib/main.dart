import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/data/data_provider/data_provider_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/firebase/firebase_core.dart';
import 'package:settlenow/notification/notification_core.dart';
import 'package:settlenow/provider/provider_core.dart';
import 'package:settlenow/router/router_config.dart';
import 'package:settlenow/theme/themes.dart';
import 'package:settlenow/util/util_core.dart';
import 'firebase/firebase_options.dart' as prod;
import 'firebase/firebase_options_dev.dart' as dev;

// TODO: Add search apis to search api

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage remoteMessage,
) async {}

FirebaseOptions get currentPlatformOptions =>
    kDebugMode
        ? dev.DefaultFirebaseOptions.currentPlatform
        : prod.DefaultFirebaseOptions.currentPlatform;

Future<void> initializeFirebaseApp() async {
  try {
    if (kIsWeb || Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: currentPlatformOptions);
    } else {
      Firebase.app();
    }
  } catch (e) {
    if (e is FirebaseException && e.code == 'duplicate-app') {
    } else {
      rethrow;
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;

  await initializeFirebaseApp();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  if (kIsWeb) {
    usePathUrlStrategy();
  } else {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  final remoteConfigService = FirebaseRemote();

  await Future.wait([
    remoteConfigService.init(),
    GoogleOauth.ensureGoogleSignInInitialized(),
    if (!kIsWeb) NotificationInterfaceHandler.initializeChannels(),
    SessionManager.instance.initialize(),
  ]);

  final AuthRepository authRepository = AuthRepository(AuthDataProvider());
  final AuthBloc authBloc = AuthBloc(authRepository);

  AppRouterConfig.initializeRouter(authBloc);

  runApp(MyApp(authBloc: authBloc, remoteConfigService: remoteConfigService));
}

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;
  final FirebaseRemote remoteConfigService;

  const MyApp({
    super.key,
    required this.authBloc,
    required this.remoteConfigService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(AuthDataProvider()),
        ),
        RepositoryProvider<RoomDashboardRepository>(
          create:
              (context) => RoomDashboardRepository(RoomDashboardDataProvider()),
        ),
        RepositoryProvider<QuicksplitRepository>(
          create: (context) => QuicksplitRepository(QuicksplitDataProvider()),
        ),
        RepositoryProvider<LendenDashboardRepository>(
          create:
              (context) =>
                  LendenDashboardRepository(LendenDashboardDataProvider()),
        ),
        RepositoryProvider<PersonalExpenseDashboardRepository>(
          create:
              (context) => PersonalExpenseDashboardRepository(
                PersonalExpenseDashboardDataProvider(),
              ),
        ),
        RepositoryProvider<PersonalMonthlyExpenseRepository>(
          create:
              (context) => PersonalMonthlyExpenseRepository(
                PersonalMonthlyExpenseDataProvider(),
              ),
        ),
        RepositoryProvider<LendenRoomRepository>(
          create: (context) => LendenRoomRepository(LendenRoomDataProvider()),
        ),
        RepositoryProvider<RoomRepository>(
          create: (context) => RoomRepository(RoomDataProvider()),
        ),
        RepositoryProvider<NotificationRepository>(
          create:
              (context) => NotificationRepository(NotificationDataProvider()),
        ),
        RepositoryProvider<UpdateInfoRepository>(
          create: (context) => UpdateInfoRepository(UpdateInfoDataProvider()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<UpdateInfoBloc>(
            create:
                (context) =>
                    UpdateInfoBloc(context.read<UpdateInfoRepository>())
                      ..add(UpdateInfoFetchRequested(remoteConfigService)),
          ),
          BlocProvider<AuthBloc>(
            create:
                (context) =>
                    AuthBloc(context.read<AuthRepository>())
                      ..add(AuthLoggedInUserRequested()),
          ),
          BlocProvider<QuicksplitBloc>(
            create:
                (context) =>
                    QuicksplitBloc(context.read<QuicksplitRepository>()),
          ),
          BlocProvider<RoomDashboardBloc>(
            create:
                (context) =>
                    RoomDashboardBloc(context.read<RoomDashboardRepository>()),
          ),
          BlocProvider<LendenDashboardBloc>(
            create:
                (context) => LendenDashboardBloc(
                  context.read<LendenDashboardRepository>(),
                ),
          ),
          BlocProvider<PersonalExpenseDashboardBloc>(
            create:
                (context) => PersonalExpenseDashboardBloc(
                  context.read<PersonalExpenseDashboardRepository>(),
                ),
          ),
          BlocProvider<PersonalMonthlyExpenseBloc>(
            create:
                (context) => PersonalMonthlyExpenseBloc(
                  context.read<PersonalMonthlyExpenseRepository>(),
                  context.read<PersonalExpenseDashboardBloc>(),
                ),
          ),
          BlocProvider<UserUpdateProfileCubit>(
            create:
                (context) => UserUpdateProfileCubit(
                  context.read<AuthRepository>(),
                  context.read<AuthBloc>(),
                ),
          ),
          BlocProvider<NotificationBloc>(
            create:
                (context) =>
                    NotificationBloc(context.read<NotificationRepository>()),
          ),
          BlocProvider<LendenRoomBloc>(
            create:
                (context) => LendenRoomBloc(
                  context.read<LendenRoomRepository>(),
                  context.read<LendenDashboardBloc>(),
                  context.read<NotificationBloc>(),
                ),
          ),
          BlocProvider<CreateJoinRoomCubit>(
            create:
                (context) => CreateJoinRoomCubit(
                  context.read<RoomDashboardRepository>(),
                  context.read<RoomRepository>(),
                  context.read<NotificationBloc>(),
                ),
          ),
          BlocProvider<CreateRoomCubit>(
            create:
                (context) => CreateRoomCubit(
                  context.read<LendenDashboardRepository>(),
                  context.read<LendenRoomRepository>(),
                  context.read<NotificationBloc>(),
                ),
          ),
          BlocProvider<RoomInfoCubit>(
            create:
                (context) => RoomInfoCubit(
                  context.read<RoomDashboardBloc>(),
                  context.read<RoomRepository>(),
                  context.read<NotificationBloc>(),
                ),
          ),
          BlocProvider<RoomUserCubit>(
            create:
                (context) => RoomUserCubit(
                  context.read<RoomRepository>(),
                  context.read<RoomInfoCubit>(),
                ),
          ),
          BlocProvider<RoomBloc>(
            create:
                (context) => RoomBloc(
                  context.read<RoomRepository>(),
                  context.read<RoomUserCubit>(),
                ),
          ),
          BlocProvider<RoomSettleCubit>(
            create:
                (context) => RoomSettleCubit(
                  context.read<RoomRepository>(),
                  context.read<RoomUserCubit>(),
                ),
          ),
          BlocProvider<RoomSettleUpsertCubit>(
            create:
                (context) => RoomSettleUpsertCubit(
                  context.read<RoomRepository>(),
                  context.read<RoomSettleCubit>(),
                ),
          ),
          BlocProvider<RoomCloseRequestCubit>(
            create:
                (context) =>
                    RoomCloseRequestCubit(context.read<RoomRepository>()),
          ),
          BlocProvider<RoomCloseCubit>(
            create:
                (context) => RoomCloseCubit(
                  context.read<RoomRepository>(),
                  context.read<RoomUserCubit>(),
                ),
          ),
          BlocProvider<RoomActivityCubit>(
            create:
                (context) => RoomActivityCubit(context.read<RoomRepository>()),
          ),
          BlocProvider<UserLoginActivityCubit>(
            create:
                (context) =>
                    UserLoginActivityCubit(context.read<AuthRepository>()),
          ),
          BlocProvider<FriendCubit>(
            create: (context) => FriendCubit(context.read<AuthRepository>()),
          ),
          BlocProvider<NewTransactionCubit>(
            create:
                (context) => NewTransactionCubit(
                  context.read<QuicksplitRepository>(),
                  context.read<PersonalMonthlyExpenseRepository>(),
                  context.read<LendenRoomRepository>(),
                  context.read<RoomRepository>(),
                ),
          ),
          BlocProvider<AddToPersonalExpenseBloc>(
            create:
                (context) => AddToPersonalExpenseBloc(
                  context.read<QuicksplitBloc>(),
                  context.read<QuicksplitRepository>(),
                  context.read<RoomBloc>(),
                  context.read<RoomRepository>(),
                ),
          ),
          BlocProvider<NotificationActionBloc>(
            create:
                (context) => NotificationActionBloc(
                  context.read<NotificationBloc>(),
                  context.read<NotificationRepository>(),
                ),
          ),
          BlocProvider<SettleCubit>(
            create:
                (context) => SettleCubit(
                  context.read<QuicksplitBloc>(),
                  context.read<QuicksplitRepository>(),
                ),
          ),
          BlocProvider<FilterCubit>(create: (context) => FilterCubit()),
          BlocProvider<PreferenceCubit>(
            create:
                (context) => PreferenceCubit(
                  context.read<AuthRepository>(),
                  context.read<AuthBloc>(),
                ),
          ),
        ],
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<ScreenSizeProvider>(
              create: (_) => ScreenSizeProvider(),
            ),
            ChangeNotifierProvider<PreferenceProvider>(
              create: (_) => PreferenceProvider(),
            ),
            ChangeNotifierProvider<FirebaseRemote>(
              create: (_) => FirebaseRemote(),
            ),
          ],
          builder: (context, _) {
            context.read<ScreenSizeProvider>().calculatePadding(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
              MediaQuery.of(context).orientation,
              MediaQuery.of(context).viewPadding,
            );

            return Consumer<PreferenceProvider>(
              builder: (context, preferenceProvider, _) {
                return MaterialApp.router(
                  routerConfig: AppRouterConfig.router,
                  title: 'Settle Now',
                  themeMode: preferenceProvider.getTheme,
                  theme: CustomTheme.lightTheme(context),
                  darkTheme: CustomTheme.darkTheme(context),
                  locale: Locale('en', 'IN'),
                  supportedLocales: [Locale('en', 'IN')],
                  localizationsDelegates: [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
