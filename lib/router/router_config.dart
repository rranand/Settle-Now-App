import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/screen/auth/login/login_screen.dart';
import 'package:settlenow_v2/screen/auth/signup/sigup_screen.dart';
import 'package:settlenow_v2/screen/dashboard/home/home_screen.dart';

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
          return HomeScreen();
        },
      ),
    ];
    return allRoutes;
  }

  static final _router = GoRouter(
    routes: _allRoutes(),
    initialLocation: RouterConstants.dashboardRouteName,
    observers: [observer],
    //errorBuilder: (context, state) => ErrorPage(),
  );

  static GoRouter router(BuildContext context) {
    return _router;
  }
}
