import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/screen/auth/login/login_screen.dart';
import 'package:settlenow_v2/screen/auth/signup/signup_screen.dart';
import 'package:settlenow_v2/screen/dashboard/home/home_screen.dart';
import 'package:settlenow_v2/screen/dashboard/lenden/lenden_expense_screen.dart';
import 'package:settlenow_v2/screen/dashboard/personal_expense/personal_expense_screen.dart';
import 'package:settlenow_v2/screen/dashboard/room/room_expense_screen.dart';
import 'package:settlenow_v2/screen/profile/login_activity_screen.dart';
import 'package:settlenow_v2/screen/profile/profile_edit_screen.dart';
import 'package:settlenow_v2/screen/profile/profile_screen.dart';
import 'package:settlenow_v2/util/card/add_transaction.dart';

class AppRouterConfig {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: analytics,
  );

  static _allRoutes() {
    List<RouteBase> allRoutes = [
      GoRoute(
        path: RouterConstants.loginRouteName,
        builder: (context, state) {
          return LoginScreen();
        },
      ),
      GoRoute(
        path: RouterConstants.signupRouteName,
        builder: (context, state) {
          return SignUpScreen();
        },
      ),
      GoRoute(
        path: RouterConstants.dashboardRouteName,
        builder: (context, state) {
          return AddTransaction();
        },
        routes: [
          GoRoute(
            path: RouterConstants.profileRouteName,
            builder: (context, state) {
              return ProfileScreen();
            },
            routes: [
              GoRoute(
                path: RouterConstants.profileEditRouteName,
                builder: (context, state) {
                  return ProfileEditScreen();
                },
              ),
              GoRoute(
                path: RouterConstants.loginActivityRouteName,
                builder: (context, state) {
                  return LoginActivityScreen();
                },
              ),
            ],
          ),
          GoRoute(
            path: "${RouterConstants.roomRouteName}/:id",
            builder: (context, state) {
              return RoomExpenseScreen(id: state.pathParameters["id"]!);
            },
            redirect: (context, state) {
              Map<String, String> param = state.pathParameters;

              if (param.isEmpty) {
                return RouterConstants.dashboardRouteName;
              } else {
                return null;
              }
            },
          ),
          GoRoute(
            path: "${RouterConstants.personalExpenseRouteName}/:id",
            builder: (context, state) {
              return PersonalExpenseScreen(id: state.pathParameters["id"]!);
            },
            redirect: (context, state) {
              Map<String, String> param = state.pathParameters;

              if (param.isEmpty) {
                return RouterConstants.dashboardRouteName;
              } else {
                return null;
              }
            },
          ),
          GoRoute(
            path: "${RouterConstants.lendenRouteName}/:id",
            builder: (context, state) {
              return LendenExpenseScreen(id: state.pathParameters["id"]!);
            },
            redirect: (context, state) {
              Map<String, String> param = state.pathParameters;

              if (param.isEmpty) {
                return RouterConstants.dashboardRouteName;
              } else {
                return null;
              }
            },
          ),
        ],
      ),
    ];
    return allRoutes;
  }

  static final _router = GoRouter(
    routes: _allRoutes(),
    initialLocation: RouterConstants.dashboardRouteName,
    //initialLocation: "${RouterConstants.roomRouteName}/id",
    observers: [observer],
  );

  static GoRouter router(BuildContext context) {
    return _router;
  }
}
