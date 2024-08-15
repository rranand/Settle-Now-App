import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow/routes/route_constant.dart';
import 'package:settlenow/screens/aboutus.dart';
import 'package:settlenow/screens/contactUs.dart';
import 'package:settlenow/screens/dashboard.dart';
/*
class AppRouter {
  static GoRouter returnRouter(bool isAuth) {
    GoRouter router = GoRouter(
      routes: [
        GoRoute(
          name: AppRouteConstants.dashboardRouteName,
          path: '/',
          pageBuilder: (context, state) {
            return MaterialPage(child: DashBoard());
          },
        ),
        GoRoute(
          name: AppRouteConstants.profileRouteName,
          path: '/profile/:username/:userid',
          pageBuilder: (context, state) {
            return MaterialPage(
                child: Profile(
              userid: state.params['userid']!,
              username: state.params['username']!,
            ));
          },
        ),
        GoRoute(
          name: AppRouteConstants.aboutRouteName,
          path: '/about',
          pageBuilder: (context, state) {
            return MaterialPage(child: AboutUs());
          },
        ),
        GoRoute(
          name: AppRouteConstants.contactUsRouteName,
          path: '/contact_us',
          pageBuilder: (context, state) {
            return MaterialPage(child: ContactUs());
          },
        )
      ],
      errorPageBuilder: (context, state) {
        return MaterialPage(child: ErrorPage());
      },
      redirect: (context, state) {
        if (!isAuth &&
            state.location
                .startsWith('/${AppRouteConstants.profileRouteName}')) {
          return context.namedLocation(AppRouteConstants.contactUsRouteName);
        } else {
          return null;
        }
      },
    );
    return router;
  }
}
*/