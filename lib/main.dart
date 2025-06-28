import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/lenden/dashboard/lenden_dashboard_bloc.dart';
import 'package:settlenow_v2/bloc/lenden/room/lenden_room_bloc.dart';
import 'package:settlenow_v2/bloc/personal_expense/dashboard/personal_expense_dashboard_bloc.dart';
import 'package:settlenow_v2/bloc/personal_expense/monthly_expense/personal_expense_bloc.dart';
import 'package:settlenow_v2/bloc/quicksplit/quicksplit_bloc.dart';
import 'package:settlenow_v2/bloc/room/dashboard/room_dashboard_bloc.dart';
import 'package:settlenow_v2/bloc/room/each_room/room_bloc.dart';
import 'package:settlenow_v2/cubit/lenden/create_room/create_room_cubit.dart';
import 'package:settlenow_v2/cubit/new_transaction/new_transaction_cubit.dart';
import 'package:settlenow_v2/cubit/room/create_join_room/create_join_room_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_close/room_close_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_close_request/room_close_request_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_info/room_info_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_settle/room_settle_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_settle_upsert/room_settle_upsert_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_user/room_user_cubit.dart';
import 'package:settlenow_v2/cubit/user/friend/friend_cubit.dart';
import 'package:settlenow_v2/cubit/user/user_login_activity/user_login_activity_cubit.dart';
import 'package:settlenow_v2/cubit/user/user_update_profile/user_update_profile_cubit.dart';
import 'package:settlenow_v2/data/data_provider/auth_data_provider.dart';
import 'package:settlenow_v2/data/data_provider/lenden/dashboard/lenden_dashboard_data_provider.dart';
import 'package:settlenow_v2/data/data_provider/lenden/room/lenden_room_data_provider.dart';
import 'package:settlenow_v2/data/data_provider/personal_expense/dashboard/personal_expense_dashboard_data_provider.dart';
import 'package:settlenow_v2/data/data_provider/personal_expense/monthly_expense/personal_expense_data_provider.dart';
import 'package:settlenow_v2/data/data_provider/quicksplit_data_provider.dart';
import 'package:settlenow_v2/data/data_provider/room/dashboard/room_dashboard_data_provider.dart';
import 'package:settlenow_v2/data/data_provider/room/each_room/room_data_provider.dart';
import 'package:settlenow_v2/data/repository/auth_repository.dart';
import 'package:settlenow_v2/data/repository/lenden/dashboard/lenden_dashboard_repository.dart';
import 'package:settlenow_v2/data/repository/lenden/room/lenden_room_repository.dart';
import 'package:settlenow_v2/data/repository/personal_expense/dashboard/personal_expense_dashboard_repository.dart';
import 'package:settlenow_v2/data/repository/personal_expense/monthly_expense/personal_expense_repository.dart';
import 'package:settlenow_v2/data/repository/quicksplit_repository.dart';
import 'package:settlenow_v2/data/repository/room/dashboard/room_dashboard_repository.dart';
import 'package:settlenow_v2/data/repository/room/each_room/room_repository.dart';
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
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
      ],
      child: MultiBlocProvider(
        providers: [
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
                (context) =>
                    UserUpdateProfileCubit(context.read<AuthRepository>()),
          ),

          BlocProvider<CreateJoinRoomCubit>(
            create:
                (context) => CreateJoinRoomCubit(
                  context.read<RoomDashboardRepository>(),
                ),
          ),
          BlocProvider<RoomSettleUpsertCubit>(
            create:
                (context) => RoomSettleUpsertCubit(
                  context.read<RoomRepository>(),
                  context.read<RoomSettleCubit>(),
                ),
          ),
          BlocProvider<CreateRoomCubit>(
            create:
                (context) =>
                    CreateRoomCubit(context.read<LendenDashboardRepository>()),
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
        ],
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<ScreenSizeProvider>(
              create: (_) => ScreenSizeProvider(),
            ),
            ChangeNotifierProvider<ThemeProvider>(
              create: (_) => ThemeProvider(),
            ),
          ],
          builder: (context, _) {
            context.read<ScreenSizeProvider>().calculatePadding(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
              MediaQuery.of(context).orientation,
              MediaQuery.of(context).viewPadding,
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
        ),
      ),
    );
  }
}
