import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
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
import 'package:settlenow_v2/util/handler/stream_to_listenable.dart';

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
            path: "${RouterConstants.personalExpenseRouteName}/:year/:month",
            builder: (context, state) {
              return PersonalExpenseScreen(
                year: state.pathParameters["year"]!,
                month: state.pathParameters["month"]!,
              );
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
              return LendenExpenseScreen(
                id: state.pathParameters["id"]!,
                roomName: state.extra as String?,
              );
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

  static GoRouter router(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);

    return GoRouter(
      routes: _allRoutes(),
      initialLocation: RouterConstants.dashboardRouteName,
      //initialLocation: "${RouterConstants.roomRouteName}/room_id_1",
      // initialLocation:
      //     RouterConstants.profileRouteName +
      //     RouterConstants.loginActivityRouteName,
      observers: [observer],
      refreshListenable: StreamToListenable(authBloc.stream),
      redirect: (context, state) {
        final authBlocInstance = context.read<AuthBloc>();
        String url = state.uri.toString();

        if (url.startsWith(RouterConstants.loginRouteName) ||
            url.startsWith(RouterConstants.signupRouteName)) {
          if (authBlocInstance.state is AuthLoginSuccess) {
            return RouterConstants.dashboardRouteName;
          }
        } else {
          if (authBlocInstance.state is! AuthLoginSuccess) {
            return RouterConstants.loginRouteName;
          }
        }

        return null;
      },
    );
  }
}
