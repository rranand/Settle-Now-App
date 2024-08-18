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
    List<RouteBase> allRoutes = [
      GoRoute(
        path: AppRouteConstants.loginRouteName,
        builder: (context, state) {
          return LoginPage();
        },
      ),
      GoRoute(
        path: AppRouteConstants.verifyRouteName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OtpName(
            email: extra!['email'] as String,
          );
        },
      ),
      GoRoute(
        path: AppRouteConstants.dashboardRouteName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return DashBoard(
            dash: extra!['dash'] ?? 0,
            firstTime: extra['firstTime'] ?? false,
          );
        },
      ),
      GoRoute(
        path: AppRouteConstants.inviteFriendsRouteName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return InviteFriends(
            firstTime: extra!['firstTime'] as bool,
          );
        },
      ),
      GoRoute(
        path: AppRouteConstants.onBoardingRouteName,
        builder: (context, state) {
          return onBoarding();
        },
      ),
      GoRoute(
        path: AppRouteConstants.maintainRouteName,
        builder: (context, state) {
          return Maintenance();
        },
      ),
      GoRoute(
        path: AppRouteConstants.personalExpenseRouteName + '/:date',
        builder: (context, state) {
          return Expenses(
            date: state.pathParameters['date']!,
          );
        },
      ),
      GoRoute(
        path: AppRouteConstants.lendByTitleRouteName + '/:roomkey',
        builder: (context, state) {
          return LendPage(
            roomkey: state.pathParameters['roomkey']!,
          );
        },
      ),
      GoRoute(
        path: AppRouteConstants.roomRouteName + '/:roomkey',
        builder: (context, state) {
          return RoomExpense(roomKey: state.pathParameters['roomkey']!);
        },
      ),
      GoRoute(
        path: AppRouteConstants.profileRouteName,
        builder: (context, state) {
          return Profile();
        },
      ),
      GoRoute(
        name: AppRouteConstants.aboutRouteName,
        path: '/about',
        builder: (context, state) {
          return AboutUs();
        },
      ),
      GoRoute(
        name: AppRouteConstants.contactUsRouteName,
        path: '/contact_us',
        builder: (context, state) {
          return ContactUs();
        },
      )
    ];

    if (!kIsWeb) {
      allRoutes.add(
        GoRoute(
          path: AppRouteConstants.schduleNotificationRouteName,
          builder: (context, state) {
            return ScheduleNotification();
          },
        ),
      );
      allRoutes.add(
        GoRoute(
          path: AppRouteConstants.bankTransactionRouteName,
          builder: (context, state) {
            return BankTransactions();
          },
        ),
      );
    }

    return allRoutes;
  }

  static final _router = GoRouter(
    routes: _allRoutes(),
    initialLocation: AppRouteConstants.loginRouteName,
    observers: [observer],
  );

  static GoRouter get router => _router;
}
