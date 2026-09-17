import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/firebase/firebase_core.dart';
import 'package:settlenow/notification/notification_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/provider/provider_core.dart';
import 'package:settlenow/router/router_constant.dart';
import 'package:settlenow/screen/screen_core.dart';
import 'package:settlenow/util/util_core.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  final int? initalScreenIndex;
  const HomeScreen({super.key, this.initalScreenIndex});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final InAppReview inAppReview = InAppReview.instance;
  final GlobalKey<ScaffoldState> _homeScreenkey = GlobalKey<ScaffoldState>();
  final ValueNotifier<bool> _isSearchEnabled = ValueNotifier(false);
  UserModel _loggedInUser = UserModel.empty();
  int _selectedIndex = 0;
  BottomNavigationType _selectedBottomNavigationType =
      BottomNavigationType.home;
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  final ValueNotifier<String> appVersion = ValueNotifier("");
  final ValueNotifier<bool> isNotificationAllowed = ValueNotifier(false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainScreenPadding = context.watch<ScreenSizeProvider>().getPadding;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> initializeNotification() async {
    if (kIsWeb) {
      isNotificationAllowed.value = true;
      await NotificationInterfaceHandler.fcmConfiguration(context, false);
      return;
    }

    final allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!mounted) return;
    isNotificationAllowed.value = allowed;

    await NotificationInterfaceHandler.fcmConfiguration(context, allowed);
  }

  Future<void> fetchAppVersion() async {
    appVersion.value = await getAppVersion();
  }

  String getShareMessage() {
    final shareDataMap = context.read<FirebaseRemote>().getJSON(
      RemoteConfigConstant.shareMessageConstant,
    );
    return "${shareDataMap['title']}\n\n${shareDataMap['subject']}\n\n${shareDataMap['playstore']}";
  }

  @override
  void initState() {
    super.initState();

    initializeNotification();
    fetchAppVersion();

    InAppUpdateService.checkForUpdate(context);
    NotificationInterfaceHandler.initateListeners(context);

    if (widget.initalScreenIndex != null) {
      _selectedIndex = widget.initalScreenIndex!.clamp(
        0,
        BottomNavigationType.values.length - 1,
      );
      _selectedBottomNavigationType =
          BottomNavigationType.values[_selectedIndex];
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;

      context.read<FriendCubit>().addFriendFromCache();

      final notificationState = context.read<NotificationBloc>().state;
      final unreadNotificationCountState =
          context.read<UnreadNotificationCountCubit>().state;

      if (notificationState is! NotificationFetchSuccess) {
        context.read<NotificationBloc>().add(NotificationFetch());
      }

      if (unreadNotificationCountState is! UnreadNotificationCountSuccess) {
        context
            .read<UnreadNotificationCountCubit>()
            .fetchUnreadNotificationCount();
      }
    }
  }

  void _onItemTapped(int index) {
    if (mounted) {
      _selectedIndex = index;
      _selectedBottomNavigationType = BottomNavigationType.values[index];
      _isSearchEnabled.value = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _isSearchEnabled.dispose();
    super.dispose();
  }

  Widget _privacyPolicyVersionWidget() {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ValueListenableBuilder(
            valueListenable: appVersion,
            builder: (context, _, _) {
              return Text(
                "Version ${appVersion.value}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white),
              );
            },
          ),
          InkWell(
            borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
            onTap: () async {
              launchUrl(
                Uri.parse("https://settlenow.in/privacy-policy"),
                mode: LaunchMode.inAppWebView,
                webViewConfiguration: const WebViewConfiguration(
                  enableJavaScript: true,
                ),
              );
            },
            child: Text(
              "Privacy Policy",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _drawerHandler(DrawingTitle drawingTitle) async {
    switch (drawingTitle) {
      case DrawingTitle.getNotified:
        {
          final notificationStatus =
              await context.push(RouterConstants.notificationPage) as bool?;

          if (notificationStatus != null) {
            isNotificationAllowed.value = notificationStatus;
          }
          break;
        }
      case DrawingTitle.bankTransactions:
        {
          context.push(RouterConstants.bankTransactionPage);
          break;
        }
      case DrawingTitle.preference:
        {
          context.push(RouterConstants.preferencePage);
          break;
        }
      case DrawingTitle.share:
        {
          SharePlus.instance.share(ShareParams(text: getShareMessage()));
          break;
        }
      case DrawingTitle.rateUs:
        {
          inAppReview.openStoreListing();
          break;
        }
      case DrawingTitle.aboutUs:
        {
          context.push(RouterConstants.aboutUsPage);
          break;
        }
      case DrawingTitle.profile:
        {
          context.push(RouterConstants.profileRouteName);
          break;
        }
      case DrawingTitle.logOut:
        {
          context.read<AuthBloc>().add(AuthLogoutRequested());
          break;
        }
    }
  }

  Widget _drawerWidget() {
    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: theme.drawerTheme.backgroundColor),
            currentAccountPicture: imageWidgetForCachedNetworkImage(
              _loggedInUser.profilePic,
              context,
              boxShape: BoxShape.circle,
            ),
            accountName: Text(
              _loggedInUser.name,
              style: TextStyle(color: Colors.white),
            ),
            accountEmail: Text(
              _loggedInUser.email,
              style: TextStyle(color: Colors.white),
            ),
          ),
          ...List.generate(DrawingTitle.values.length, (index) {
            return ValueListenableBuilder(
              valueListenable: isNotificationAllowed,
              builder: (BuildContext context, _, _) {
                final drawingTitle = DrawingTitle.values[index];

                if (kIsWeb && !drawingTitle.isWebCompatible) {
                  return SizedBox.shrink();
                }
                if (drawingTitle == DrawingTitle.getNotified &&
                    isNotificationAllowed.value) {
                  return SizedBox.shrink();
                }

                return ListTile(
                  onTap: () {
                    _drawerHandler(drawingTitle);
                  },
                  leading: Icon(
                    drawingTitle.icon,
                    color: Colors.white,
                    size: 22,
                  ),
                  title: Text(
                    drawingTitle.label,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  trailing: Visibility(
                    visible: drawingTitle.isBeta,
                    child: Container(
                      width: 55,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: theme.primaryColorLight),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          "Beta",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          _privacyPolicyVersionWidget(),
        ],
      ),
    );
  }

  Widget _notificationWithDot(BottomNavigationType bottomNavigationType) {
    if (bottomNavigationType == BottomNavigationType.notification) {
      return NotificationBellNavBarIcon(iconData: bottomNavigationType.icon);
    } else {
      return Icon(bottomNavigationType.icon);
    }
  }

  Widget _bottomNavigationBarWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, spreadRadius: 1),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedFontSize: 12,
          unselectedFontSize: 10,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: List.generate(
            BottomNavigationType.values.length,
            (index) => BottomNavigationBarItem(
              icon: _notificationWithDot(BottomNavigationType.values[index]),
              label: BottomNavigationType.values[index].label,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomNavigatorBodyHandler(
    BottomNavigationType bottomNavigationType,
  ) {
    switch (bottomNavigationType) {
      case BottomNavigationType.quicksplit:
        return QuickSplitDashboardScreen(isSearchEnabled: _isSearchEnabled);
      case BottomNavigationType.personal:
        return PersonalExpenseDashboardScreen(
          isSearchEnabled: _isSearchEnabled,
        );
      case BottomNavigationType.lenden:
        return LendenDashboardScreen(isSearchEnabled: _isSearchEnabled);
      case BottomNavigationType.notification:
        return NotificationScreen();
      default:
        return RoomDashboardScreen(isSearchEnabled: _isSearchEnabled);
    }
  }

  PreferredSizeWidget? _bottomNavigatorAppBarHandler(
    BottomNavigationType bottomNavigationType,
  ) {
    List<Widget> appBarActions = [];

    if (bottomNavigationType.isSearchEnabled) {
      appBarActions = [
        InkWell(
          borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
          child: Icon(Icons.search),
          onTap: () {
            _isSearchEnabled.value = !_isSearchEnabled.value;
          },
        ),
      ];
    }

    return AppBar(
      leading: appBarLeadingButton(
        context,
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            if (_homeScreenkey.currentState!.isDrawerOpen) {
              _homeScreenkey.currentState!.closeDrawer();
            } else {
              _homeScreenkey.currentState!.openDrawer();
            }
          },
        ),
      ),
      titleSpacing: _mainScreenPadding.left,
      title: Text("Settle Now"),
      centerTitle: false,
      actions: appBarActionButton(context, appBarActions),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseRemote>(
      builder: (context, firebaseRemote, _) {
        context.read<UpdateInfoBloc>().add(
          UpdateInfoFetchRequested(firebaseRemote),
        );
        return BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLogoutFailure) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showNormalSnackBar(context, state.error);
              });
            } else if (state is AuthInitial) {
              resetAllBlocs(context);
              while (context.canPop()) {
                context.pop();
              }
              context.pushReplacement(RouterConstants.loginRouteName);
            }
          },
          builder: (context, state) {
            if (state is AuthLoginFailure) {
              return ErrorPage();
            } else if (state is AuthLogoutLoading) {
              return Scaffold(
                appBar: AppBar(backgroundColor: Colors.transparent),
                body: LoadingPage(),
              );
            } else {
              return Scaffold(
                key: _homeScreenkey,
                appBar: _bottomNavigatorAppBarHandler(
                  _selectedBottomNavigationType,
                ),
                body: _bottomNavigatorBodyHandler(
                  _selectedBottomNavigationType,
                ),
                bottomNavigationBar: _bottomNavigationBarWidget(),
                drawer: _drawerWidget(),
              );
            }
          },
        );
      },
    );
  }
}
