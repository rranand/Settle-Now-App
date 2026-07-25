import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/router/router_constant.dart';
import 'package:settlenow/screen/screen_core.dart';
import 'package:settlenow/util/util_core.dart';

class AppRouterConfig {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: analytics,
  );

  static String getPreviousPath(Uri uri) {
    String url = uri.toString();
    List<String> urlArr = url.split("/");
    urlArr = urlArr.getRange(0, max(1, urlArr.length - 1)).toList();
    return urlArr.join("/");
  }

  static late final GoRouter _router;

  static List<RouteBase> _allRoutes() {
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
        path: RouterConstants.updatePage,
        builder: (context, state) {
          UpdateInfoModel data = state.extra as UpdateInfoModel;
          return UpdatePage(data: data);
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
      GoRoute(
        path: RouterConstants.maintenancePage,
        builder: (context, state) {
          return MaintenancePage();
        },
      ),
      GoRoute(
        path: RouterConstants.dashboardRouteName,
        builder: (context, state) {
          Map<String, dynamic>? data = state.extra as Map<String, dynamic>?;
          if (data == null ||
              data.isEmpty ||
              !data.containsKey('initalIndex')) {
            return AuthGate(child: HomeScreen());
          }
          return AuthGate(
            child: HomeScreen(initalScreenIndex: data["initalIndex"]),
          );
        },
        routes: [
          GoRoute(
            path: "${RouterConstants.deepLinkJoinRoom}/:id",
            builder: (context, state) {
              return AuthGate(
                child: DeepLinkJoin(
                  transactionType: TransactionType.room,
                  id: state.pathParameters["id"]!,
                ),
              );
            },
          ),
          GoRoute(
            path: RouterConstants.preferencePage,
            builder: (context, state) {
              return AuthGate(child: PreferenceScreen());
            },
          ),
          GoRoute(
            path: RouterConstants.notificationPage,
            builder: (context, state) {
              return GetNotified();
            },
          ),
          GoRoute(
            path: RouterConstants.aboutUsPage,
            builder: (context, state) {
              return AboutUsPage();
            },
          ),
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
                String? id = param['id'];
                if (id == null) {
                  return RouterConstants.dashboardRouteName;
                } else if (CustomValidator.isValidObjectId(id)) {
                  return null;
                } else if (id.length == 7) {
                  return "${RouterConstants.deepLinkJoinRoom}/$id";
                } else {
                  return RouterConstants.dashboardRouteName;
                }
              }
            },
            routes: [
              GoRoute(
                path: RouterConstants.settingPage,
                builder: (context, state) {
                  return AuthGate(
                    child: SettingPage(
                      transactionType: TransactionType.room,
                      id: state.pathParameters["id"]!,
                    ),
                  );
                },
              ),
              GoRoute(
                path: RouterConstants.roomActivityRouteName,
                builder: (context, state) {
                  return AuthGate(
                    child: RoomActivityPage(id: state.pathParameters["id"]!),
                  );
                },
              ),
              GoRoute(
                path: "${RouterConstants.roomActivityRouteName}/:transactionID",
                builder: (context, state) {
                  String transactionID = state.pathParameters["transactionID"]!;
                  return AuthGate(
                    child: RoomActivityPage(
                      id: state.pathParameters["id"]!,
                      transactionID: transactionID,
                    ),
                  );
                },
              ),
              GoRoute(
                path: RouterConstants.inviteMember,
                builder: (context, state) {
                  Map<String, dynamic> data =
                      state.extra as Map<String, dynamic>;
                  return AuthGate(
                    child: InviteMember(
                      userID: [],
                      transactionType: data["transactionType"],
                      inviteMember: true,
                    ),
                  );
                },
                redirect: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  if (extra == null ||
                      extra.isEmpty ||
                      !extra.containsKey("transactionType")) {
                    return getPreviousPath(state.uri);
                  } else {
                    return null;
                  }
                },
              ),
              GoRoute(
                path: RouterConstants.roomAddExpenseRouteName,
                builder: (context, state) {
                  return AuthGate(child: AddTransaction());
                },
                routes: [
                  GoRoute(
                    path: RouterConstants.inviteMember,
                    builder: (context, state) {
                      Map<String, dynamic> data =
                          state.extra as Map<String, dynamic>;
                      return AuthGate(
                        child: InviteMember(
                          userID: data["userID"],
                          transactionType: data["transactionType"],
                          inviteMember: false,
                        ),
                      );
                    },
                    redirect: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      if (extra == null ||
                          extra.isEmpty ||
                          !extra.containsKey("userID") ||
                          !extra.containsKey("transactionType")) {
                        return getPreviousPath(state.uri);
                      } else {
                        return null;
                      }
                    },
                  ),
                ],
              ),
              GoRoute(
                path: RouterConstants.roomAddBulkExpenseRouteName,
                builder: (context, state) {
                  return AuthGate(child: BulkTransaction());
                },
              ),
              GoRoute(
                path: RouterConstants.roomEditExpenseRouteName,
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
                routes: [
                  GoRoute(
                    path: RouterConstants.inviteMember,
                    builder: (context, state) {
                      Map<String, dynamic> data =
                          state.extra as Map<String, dynamic>;
                      return AuthGate(
                        child: InviteMember(
                          userID: data["userID"],
                          transactionType: data["transactionType"],
                          inviteMember: false,
                        ),
                      );
                    },
                    redirect: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      if (extra == null ||
                          extra.isEmpty ||
                          !extra.containsKey("userID") ||
                          !extra.containsKey("transactionType")) {
                        return RouterConstants.quickSplitAddExpenseRouteName;
                      } else {
                        return null;
                      }
                    },
                  ),
                ],
              ),
              GoRoute(
                path: RouterConstants.roomSettleAddRouteName,
                builder: (context, state) {
                  final id = state.pathParameters['id'];
                  return AuthGate(child: SettleExpense(roomID: id!));
                },
                redirect: (context, state) {
                  final id = state.pathParameters['id'];

                  if (id == null) {
                    return RouterConstants.dashboardRouteName;
                  } else {
                    return null;
                  }
                },
              ),
              GoRoute(
                path: RouterConstants.roomSettleEditRouteName,
                builder: (context, state) {
                  final id = state.pathParameters['id'];
                  final RoomSettleModel data = state.extra as RoomSettleModel;
                  return AuthGate(
                    child: SettleExpense(roomID: id!, transactionData: data),
                  );
                },
                redirect: (context, state) {
                  final id = state.pathParameters['id'];
                  final extra = state.extra;

                  if (id == null || extra == null) {
                    return RouterConstants.dashboardRouteName;
                  } else {
                    return null;
                  }
                },
              ),
            ],
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
                path: RouterConstants.settingPage,
                builder: (context, state) {
                  return AuthGate(
                    child: SettingPage(
                      transactionType: TransactionType.lenden,
                      id: state.pathParameters["id"]!,
                    ),
                  );
                },
              ),
              GoRoute(
                path: RouterConstants.inviteMember,
                builder: (context, state) {
                  Map<String, dynamic> data =
                      state.extra as Map<String, dynamic>;
                  return AuthGate(
                    child: InviteMember(
                      userID: [],
                      transactionType: data["transactionType"],
                      inviteMember: true,
                    ),
                  );
                },
                redirect: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  if (extra == null ||
                      extra.isEmpty ||
                      !extra.containsKey("transactionType")) {
                    return getPreviousPath(state.uri);
                  } else {
                    return null;
                  }
                },
              ),
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
            routes: [
              GoRoute(
                path: RouterConstants.inviteMember,
                builder: (context, state) {
                  Map<String, dynamic> data =
                      state.extra as Map<String, dynamic>;
                  return AuthGate(
                    child: InviteMember(
                      userID: data["userID"],
                      transactionType: data["transactionType"],
                      inviteMember: false,
                    ),
                  );
                },
                redirect: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  if (extra == null ||
                      extra.isEmpty ||
                      !extra.containsKey("userID") ||
                      !extra.containsKey("transactionType")) {
                    return RouterConstants.quickSplitAddExpenseRouteName;
                  } else {
                    return null;
                  }
                },
              ),
            ],
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
            routes: [
              GoRoute(
                path: RouterConstants.inviteMember,
                builder: (context, state) {
                  Map<String, dynamic> data =
                      state.extra as Map<String, dynamic>;
                  return AuthGate(
                    child: InviteMember(
                      userID: data["userID"],
                      transactionType: data["transactionType"],
                      inviteMember: false,
                    ),
                  );
                },
                redirect: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  if (extra == null ||
                      extra.isEmpty ||
                      !extra.containsKey("userID") ||
                      !extra.containsKey("transactionType")) {
                    return RouterConstants.quickSplitAddExpenseRouteName;
                  } else {
                    return null;
                  }
                },
              ),
            ],
          ),
        ],
      ),
    ];
    return allRoutes;
  }

  static void initializeRouter(AuthBloc authBloc) {
    _router = GoRouter(
      routes: _allRoutes(),
      initialLocation: RouterConstants.dashboardRouteName,
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

        return null;
      },
      errorBuilder: (context, state) => ErrorPage(),
    );
  }

  static GoRouter get router => _router;
}
