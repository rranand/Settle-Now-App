import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/core.dart';
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
import 'package:settlenow_v2/util/handler/stream_to_listenable.dart';
import 'package:settlenow_v2/util/widgets/auth_gate.dart';

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
          return AuthGate(child: HomeScreen());
        },
        routes: [
          GoRoute(
            path: RouterConstants.profileRouteName,
            builder: (context, state) {
              return AuthGate(child: ProfileScreen());
            },
            routes: [
              GoRoute(
                path: RouterConstants.profileEditRouteName,
                builder: (context, state) {
                  return AuthGate(child: ProfileEditScreen());
                },
              ),
              GoRoute(
                path: RouterConstants.loginActivityRouteName,
                builder: (context, state) {
                  return AuthGate(child: LoginActivityScreen());
                },
              ),
            ],
          ),
          GoRoute(
            path: "${RouterConstants.roomRouteName}/:id",
            builder: (context, state) {
              return AuthGate(
                child: RoomExpenseScreen(id: state.pathParameters["id"]!),
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
            path: "${RouterConstants.personalExpenseRouteName}/:year/:month",
            builder: (context, state) {
              return AuthGate(
                child: PersonalExpenseScreen(
                  year: state.pathParameters["year"]!,
                  month: state.pathParameters["month"]!,
                ),
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
            routes: [
              GoRoute(
                path: RouterConstants.personalExpenseAddExpenseRouteName,
                builder: (context, state) {
                  return AuthGate(child: AddTransaction());
                },
              ),
              GoRoute(
                path: RouterConstants.personalExpenseEditExpenseRouteName,
                builder: (context, state) {
                  TransactionModel data = state.extra as TransactionModel;
                  return AuthGate(child: AddTransaction(transactionData: data));
                },
                redirect: (context, state) {
                  final extra = state.extra;

                  if (extra == null) {
                    return RouterConstants.dashboardRouteName;
                  } else {
                    return null;
                  }
                },
              ),
            ],
          ),
          GoRoute(
            path: "${RouterConstants.lendenRouteName}/:id",
            builder: (context, state) {
              return AuthGate(
                child: LendenExpenseScreen(
                  id: state.pathParameters["id"]!,
                  roomName: state.extra as String?,
                ),
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
            routes: [
              GoRoute(
                path: RouterConstants.lendenAddExpenseRouteName,
                builder: (context, state) {
                  return AuthGate(child: AddTransaction());
                },
              ),
              GoRoute(
                path: RouterConstants.lendenEditExpenseRouteName,
                builder: (context, state) {
                  TransactionModel data = state.extra as TransactionModel;
                  return AuthGate(child: AddTransaction(transactionData: data));
                },
                redirect: (context, state) {
                  final extra = state.extra;

                  if (extra == null) {
                    return RouterConstants.dashboardRouteName;
                  } else {
                    return null;
                  }
                },
              ),
            ],
          ),
          GoRoute(
            path: RouterConstants.quickSplitAddExpenseRouteName,
            builder: (context, state) {
              return AuthGate(child: AddTransaction());
            },
          ),
          GoRoute(
            path: RouterConstants.quickSplitEditExpenseRouteName,
            builder: (context, state) {
              TransactionModel data = state.extra as TransactionModel;
              return AuthGate(child: AddTransaction(transactionData: data));
            },
            redirect: (context, state) {
              final extra = state.extra;

              if (extra == null) {
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
      //initialLocation:
      //  RouterConstants.profileRouteName +
      //RouterConstants.loginActivityRouteName,
      observers: [observer],
      refreshListenable: StreamToListenable(authBloc.stream),
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        final url = state.uri.toString();

        if (authState is AuthInitial || authState is AuthLoginLoading) {
          return null;
        }

        final isLoggedIn = authState is AuthLoginSuccess;

        final isAuthPage =
            url.startsWith(RouterConstants.loginRouteName) ||
            url.startsWith(RouterConstants.signupRouteName);

        if (!isLoggedIn && !isAuthPage) {
          return RouterConstants.loginRouteName;
        }

        if (isLoggedIn && isAuthPage) {
          return RouterConstants.dashboardRouteName;
        }

        return null;
      },
    );
  }
}
