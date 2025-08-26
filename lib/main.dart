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
import 'package:settlenow_v2/firebase/firebase_remote.dart';
import 'package:settlenow_v2/notification/notification_interface_handler.dart';
import 'package:settlenow_v2/bloc/add_to_personal_expense/add_to_personal_expense_bloc.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/lenden/dashboard/lenden_dashboard_bloc.dart';
import 'package:settlenow_v2/bloc/lenden/room/lenden_room_bloc.dart';
import 'package:settlenow_v2/bloc/notification/notification_bloc.dart';
import 'package:settlenow_v2/bloc/notification_action/notification_action_bloc.dart';
import 'package:settlenow_v2/bloc/personal_expense/dashboard/personal_expense_dashboard_bloc.dart';
import 'package:settlenow_v2/bloc/personal_expense/monthly_expense/personal_expense_bloc.dart';
import 'package:settlenow_v2/bloc/quicksplit/quicksplit_bloc.dart';
import 'package:settlenow_v2/bloc/room/dashboard/room_dashboard_bloc.dart';
import 'package:settlenow_v2/bloc/room/each_room/room_bloc.dart';
import 'package:settlenow_v2/bloc/update_info/update_info_bloc.dart';
import 'package:settlenow_v2/cubit/filter/filter_cubit.dart';
import 'package:settlenow_v2/cubit/lenden/create_room/create_room_cubit.dart';
import 'package:settlenow_v2/cubit/new_transaction/new_transaction_cubit.dart';
import 'package:settlenow_v2/cubit/quicksplit/settle/settle_cubit.dart';
import 'package:settlenow_v2/cubit/room/create_join_room/create_join_room_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_close/room_close_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_close_request/room_close_request_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_info/room_info_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_settle/room_settle_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_settle_upsert/room_settle_upsert_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_user/room_user_cubit.dart';
import 'package:settlenow_v2/cubit/user/friend/friend_cubit.dart';
import 'package:settlenow_v2/cubit/user/preference/preference_cubit.dart';
import 'package:settlenow_v2/cubit/user/user_login_activity/user_login_activity_cubit.dart';
import 'package:settlenow_v2/cubit/user/user_update_profile/user_update_profile_cubit.dart';
import 'package:settlenow_v2/data/data_provider/auth_data_provider.dart';
import 'package:settlenow_v2/data/data_provider/lenden/dashboard/lenden_dashboard_data_provider.dart';
import 'package:settlenow_v2/data/data_provider/lenden/room/lenden_room_data_provider.dart';
import 'package:settlenow_v2/data/data_provider/notification_data_provider.dart';
import 'package:settlenow_v2/data/data_provider/personal_expense/dashboard/personal_expense_dashboard_data_provider.dart';
import 'package:settlenow_v2/data/data_provider/personal_expense/monthly_expense/personal_expense_data_provider.dart';
import 'package:settlenow_v2/data/data_provider/quicksplit_data_provider.dart';
import 'package:settlenow_v2/data/data_provider/room/dashboard/room_dashboard_data_provider.dart';
import 'package:settlenow_v2/data/data_provider/room/each_room/room_data_provider.dart';
import 'package:settlenow_v2/data/repository/auth_repository.dart';
import 'package:settlenow_v2/data/repository/lenden/dashboard/lenden_dashboard_repository.dart';
import 'package:settlenow_v2/data/repository/lenden/room/lenden_room_repository.dart';
import 'package:settlenow_v2/data/repository/notification_repository.dart';
import 'package:settlenow_v2/data/repository/personal_expense/dashboard/personal_expense_dashboard_repository.dart';
import 'package:settlenow_v2/data/repository/personal_expense/monthly_expense/personal_expense_repository.dart';
import 'package:settlenow_v2/data/repository/quicksplit_repository.dart';
import 'package:settlenow_v2/data/repository/room/dashboard/room_dashboard_repository.dart';
import 'package:settlenow_v2/data/repository/room/each_room/room_repository.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/provider/preference_provider.dart';
import 'package:settlenow_v2/router/router_config.dart';
import 'package:settlenow_v2/theme/themes.dart';
import 'package:settlenow_v2/util/oAuth/google_oauth.dart';
import 'firebase/firebase_options.dart' as firebase_prod;
import 'firebase/firebase_options_dev.dart' as firebase_dev;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage remoteMessage,
) async {}

Future<void> initializeFirebaseApp() async {
  try {
    if (kIsWeb || Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options:
            kDebugMode
                ? firebase_dev.DefaultFirebaseOptions.currentPlatform
                : firebase_prod.DefaultFirebaseOptions.currentPlatform,
      );
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

  final remoteConfigService = FirebaseRemote();
  await remoteConfigService.init();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  if (kIsWeb) {
    usePathUrlStrategy();
  } else {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await NotificationInterfaceHandler.initializeChannels();
    await GoogleOauth.ensureGoogleSignInInitialized();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }
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
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<UpdateInfoBloc>(
            create:
                (context) =>
                    UpdateInfoBloc()
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
          BlocProvider<LendenRoomBloc>(
            create:
                (context) => LendenRoomBloc(
                  context.read<LendenRoomRepository>(),
                  context.read<LendenDashboardBloc>(),
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
            PreferenceProvider preferenceProvider =
                context.watch<PreferenceProvider>();

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
        ),
      ),
    );
  }
}
