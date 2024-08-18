import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow/routes/route_constant.dart';
import 'package:settlenow/screens/BankTransactions.dart';
import 'package:settlenow/screens/ScheduleNotification.dart';
import 'package:settlenow/screens/aboutus.dart';
import 'package:settlenow/screens/contactUs.dart';
import 'package:settlenow/screens/dashboard.dart';
import 'package:settlenow/screens/expenses.dart';
import 'package:settlenow/screens/inviteFriends.dart';
import 'package:settlenow/screens/lendPage.dart';
import 'package:settlenow/screens/loginPage.dart';
import 'package:settlenow/screens/maintain.dart';
import 'package:settlenow/screens/onBoarding.dart';
import 'package:settlenow/screens/otpName.dart';
import 'package:settlenow/screens/profile.dart';
import 'package:settlenow/screens/rooms.dart';

class AppRouter {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  static _allRoutes() {
    List<RouteBase> androidRoutes = [];
    if (!kIsWeb) {
      androidRoutes.add(
        GoRoute(
          path: AppRouteConstants.schduleNotificationRouteName.substring(1),
          builder: (context, state) {
            return ScheduleNotification();
          },
        ),
      );
      androidRoutes.add(
        GoRoute(
          path: AppRouteConstants.bankTransactionRouteName.substring(1),
          builder: (context, state) {
            return BankTransactions();
          },
        ),
      );
    }
    List<RouteBase> allRoutes = [
      GoRoute(
          path: AppRouteConstants.loginRouteName,
          builder: (context, state) {
            return LoginPage();
          },
          routes: [
            GoRoute(
              path: AppRouteConstants.verifyRouteName.substring(1),
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                if (extra == null) {
                  return OtpName(
                    email: "",
                  );
                }
                return OtpName(
                  email: extra['email'] as String,
                );
              },
            ),
          ]),
      GoRoute(
        path: AppRouteConstants.maintainRouteName,
        builder: (context, state) {
          return Maintenance();
        },
      ),
      GoRoute(
          path: AppRouteConstants.dashboardRouteName,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;

            if (extra == null) {
              return DashBoard(
                dash: 0,
                firstTime: false,
              );
            }

            return DashBoard(
              dash: extra['dash'] ?? 0,
              firstTime: extra['firstTime'] ?? false,
            );
          },
          routes: [
            GoRoute(
              path: AppRouteConstants.personalExpenseRouteName.substring(1) +
                  '/:date',
              builder: (context, state) {
                return Expenses(
                  date: state.pathParameters['date']!,
                );
              },
            ),
            GoRoute(
              path: AppRouteConstants.lendByTitleRouteName.substring(1) +
                  '/:roomkey',
              builder: (context, state) {
                return LendPage(
                  roomkey: state.pathParameters['roomkey']!,
                );
              },
            ),
            GoRoute(
              path: AppRouteConstants.roomRouteName.substring(1) + '/:roomkey',
              builder: (context, state) {
                return RoomExpense(roomKey: state.pathParameters['roomkey']!);
              },
            ),
            GoRoute(
              path: AppRouteConstants.profileRouteName.substring(1),
              builder: (context, state) {
                return Profile();
              },
            ),
            GoRoute(
              path: AppRouteConstants.aboutRouteName.substring(1),
              builder: (context, state) {
                return AboutUs();
              },
            ),
            GoRoute(
              path: AppRouteConstants.contactUsRouteName.substring(1),
              builder: (context, state) {
                return ContactUs();
              },
            ),
            GoRoute(
              path: AppRouteConstants.inviteFriendsRouteName.substring(1),
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                if (extra == null) {
                  return InviteFriends(
                    firstTime: false,
                  );
                }
                return InviteFriends(
                  firstTime: extra['firstTime'] as bool,
                );
              },
            ),
            GoRoute(
              path: AppRouteConstants.onBoardingRouteName.substring(1),
              builder: (context, state) {
                return onBoarding();
              },
            ),
            ...androidRoutes
          ]),
    ];

    return allRoutes;
  }

  static final _router = GoRouter(
    routes: _allRoutes(),
    initialLocation: AppRouteConstants.loginRouteName,
    observers: [observer],
  );

  static GoRouter get router => _router;
}
