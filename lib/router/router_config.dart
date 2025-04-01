import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/screen/auth/login/login_screen.dart';

class AppRouterConfig {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: analytics,
  );

  static _allRoutes() {
    //List<RouteBase> androidRoutes = [];
    // if (!kIsWeb) {
    //   androidRoutes.add(
    //     GoRoute(
    //       path: RouterConstants.schduleNotificationRouteName.substring(1),
    //       builder: (context, state) {
    //         return ScheduleNotification();
    //       },
    //     ),
    //   );
    //   androidRoutes.add(
    //     GoRoute(
    //       path: RouterConstants.bankTransactionRouteName.substring(1),
    //       builder: (context, state) {
    //         return BankTransactions();
    //       },
    //     ),
    //   );
    // }
    // List<RouteBase> allRoutes = [
    //   GoRoute(
    //     path: RouterConstants.loginRouteName,
    //     builder: (context, state) {
    //       return LoginScreen();
    //     },
    // routes: [
    //   GoRoute(
    //     path: RouterConstants.verifyRouteName.substring(1),
    //     builder: (context, state) {
    //       final extra = state.extra as Map<String, dynamic>?;
    //       if (extra == null) {
    //         return OtpName(email: "", ipAddress: "");
    //       }
    //       return OtpName(
    //         email: extra['email'] as String,
    //         ipAddress: extra['ipAddress'] as String,
    //       );
    //     },
    //   ),
    // ],
    // ),
    // GoRoute(
    //   path: RouterConstants.maintainRouteName,
    //   builder: (context, state) {
    //     return Maintenance();
    //   },
    // ),
    // GoRoute(
    //   path: RouterConstants.dashboardRouteName,
    //   builder: (context, state) {
    //     final extra = state.extra as Map<String, dynamic>?;

    //     if (extra == null) {
    //       return DashBoard(dash: 0, firstTime: false);
    //     }

    //     return DashBoard(
    //       dash: extra['dash'] ?? 0,
    //       firstTime: extra['firstTime'] ?? false,
    //     );
    //   },
    //   routes: [
    //     GoRoute(
    //       path:
    //           '${RouterConstants.personalExpenseRouteName.substring(1)}/:date',
    //       builder: (context, state) {
    //         return Expenses(date: state.pathParameters['date']!);
    //       },
    //     ),
    //     GoRoute(
    //       path:
    //           '${RouterConstants.lendByTitleRouteName.substring(1)}/:roomkey',
    //       builder: (context, state) {
    //         return LendPage(roomkey: state.pathParameters['roomkey']!);
    //       },
    //     ),
    //     GoRoute(
    //       path: '${RouterConstants.roomRouteName.substring(1)}/:roomkey',
    //       builder: (context, state) {
    //         return RoomExpense(roomKey: state.pathParameters['roomkey']!);
    //       },
    //     ),
    //     GoRoute(
    //       path: RouterConstants.profileRouteName.substring(1),
    //       builder: (context, state) {
    //         return Profile();
    //       },
    //     ),
    //     GoRoute(
    //       path: RouterConstants.aboutRouteName.substring(1),
    //       builder: (context, state) {
    //         return AboutUs();
    //       },
    //     ),
    //     GoRoute(
    //       path: RouterConstants.contactUsRouteName.substring(1),
    //       builder: (context, state) {
    //         return ContactUs();
    //       },
    //     ),
    //     GoRoute(
    //       path: RouterConstants.inviteFriendsRouteName.substring(1),
    //       builder: (context, state) {
    //         final extra = state.extra as Map<String, dynamic>?;
    //         if (extra == null) {
    //           return InviteFriends(firstTime: false);
    //         }
    //         return InviteFriends(firstTime: extra['firstTime'] as bool);
    //       },
    //     ),
    //     GoRoute(
    //       path: RouterConstants.notificationPermissionRouteName.substring(1),
    //       builder: (context, state) {
    //         final extra = state.extra as Map<String, dynamic>?;
    //         if (extra == null) {
    //           return NotificationPermission(firstTime: false);
    //         }
    //         return NotificationPermission(
    //           firstTime: extra['firstTime'] as bool,
    //         );
    //       },
    //     ),
    //     GoRoute(
    //       path: RouterConstants.onBoardingRouteName.substring(1),
    //       builder: (context, state) {
    //         return onBoarding();
    //       },
    //     ),
    //     ...androidRoutes,
    //   ],
    // ),
    // GoRoute(
    //   path: '${RouterConstants.deepLinkJoinRoom}/:roomkey',
    //   builder: (context, state) {
    //     return RoomJoin(roomKey: state.pathParameters['roomkey']!);
    //   },
    // ),
    // GoRoute(
    //   path: '${RouterConstants.deepLinkJoinLend}/:roomkey',
    //   builder: (context, state) {
    //     return RoomJoin(roomKey: state.pathParameters['roomkey']!);
    //   },
    // ),
    // GoRoute(
    //   path: RouterConstants.errorPageRouteName,
    //   builder: (context, state) {
    //     return ErrorPage();
    //   },
    // ),
    //];

    List<RouteBase> allRoutes = [
      GoRoute(
        path: RouterConstants.loginRouteName,
        builder: (context, state) {
          return LoginScreen();
        },
      ),
    ];
    return allRoutes;
  }

  static final _router = GoRouter(
    routes: _allRoutes(),
    initialLocation: RouterConstants.loginRouteName,
    observers: [observer],
    //errorBuilder: (context, state) => ErrorPage(),
  );

  static GoRouter router(BuildContext context) {
    return _router;
  }
}

// class AppRouter {
//   static _allRoutes() {
//     List<RouteBase> routes = [
//       GoRoute(
//         path: RouteConstants.loginRouteName,
//         builder: (context, state) {
//           return LoginPage();
//         },
//         routes: [
//           GoRoute(
//             path: RouteConstants.forgotPasswordRouteName,
//             builder: (context, state) {
//               return ForgotPasswordPage();
//             },
//           )
//         ],
//       ),
//       GoRoute(
//           path: RouteConstants.signupRouteName,
//           builder: (context, state) {
//             return SignUpPage();
//           },
//           routes: [
//             GoRoute(
//               path: RouteConstants.signupSuccessRouteName,
//               builder: (context, state) {
//                 return SignUpSuccessPage();
//               },
//             )
//           ]),
//       GoRoute(
//         path: RouteConstants.dashboardRouteName,
//         builder: (context, state) {
//           return HomeScreenPage();
//         },
//         routes: [
//           GoRoute(
//               path: "${RouteConstants.userRouteName}/:username",
//               builder: (context, state) {
//                 return UserPage(
//                   userName: state.pathParameters['username']!,
//                 );
//               },
//               routes: [
//                 GoRoute(
//                   path: RouteConstants.userEditRouteName,
//                   builder: (context, state) {
//                     return UserEditPage();
//                   },
//                 ),
//               ]),
//           GoRoute(
//             path: RouteConstants.profileRouteName,
//             builder: (context, state) {
//               return ProfileInfoPage();
//             },
//           ),
//           GoRoute(
//             path: RouteConstants.aboutRouteName,
//             builder: (context, state) {
//               return AboutUsPage();
//             },
//           ),
//           GoRoute(
//             path: RouteConstants.eventRouteName,
//             builder: (context, state) {
//               return ExploreEventPage();
//             },
//             routes: [
//               GoRoute(
//                 path: RouteConstants.createEventRouteName,
//                 builder: (context, state) {
//                   return CreateEventPage();
//                 },
//               ),
//               GoRoute(
//                 path: "/:eventID",
//                 builder: (context, state) {
//                   return EventPage(
//                     eventID: state.pathParameters['eventID']!,
//                   );
//                 },
//                 routes: [
//                   GoRoute(
//                     path: RouteConstants.editEventRouteName,
//                     builder: (context, state) {
//                       return EditEventPage();
//                     },
//                     redirect: (context, state) {
//                       final eventBloc = BlocProvider.of<EventBloc>(context);
//                       if (eventBloc.state.selectedEvent != null) {
//                         if (eventBloc.state.selectedEvent!.isHost) {
//                           return null;
//                         }
//                       }
//                       return "${RouteConstants.eventRouteName}/${state.pathParameters['eventID']}";
//                     },
//                   ),
//                   GoRoute(
//                     path: RouteConstants.commentEventRouteName,
//                     builder: (context, state) {
//                       return EventCommentScreen();
//                     },
//                   )
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     ];

//     return routes;
//   }

//   static GoRouter router(BuildContext context) {
//     final authBloc = BlocProvider.of<AuthBloc>(context);

//     return GoRouter(
//       routes: _allRoutes(),
//       initialLocation: RouteConstants.dashboardRouteName,
//       //initialLocation: RouteConstants.loginRouteName,
//       refreshListenable: StreamToListenable(authBloc.stream),
//       redirect: (context, state) {
//         final authBlocInstance = context.read<AuthBloc>();
//         String url = state.uri.toString();
//         if (url.startsWith(RouteConstants.loginRouteName) ||
//             url.startsWith(RouteConstants.signupRouteName)) {
//           if (authBlocInstance.state is AuthLoginSuccess) {
//             return RouteConstants.dashboardRouteName;
//           }
//         } else {
//           if (authBlocInstance.state is! AuthLoginSuccess) {
//             return RouteConstants.loginRouteName;
//           }
//         }

//         return null;
//       },
//     );
//   }
// }
