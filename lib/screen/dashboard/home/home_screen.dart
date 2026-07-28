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

  void populateData() async {
    if (kIsWeb) {
      isNotificationAllowed.value = true;
      NotificationInterfaceHandler.fcmConfiguration(context, false);
    } else {
      isNotificationAllowed.value =
          await AwesomeNotifications().isNotificationAllowed();
      if (mounted) {
        NotificationInterfaceHandler.fcmConfiguration(
          context,
          isNotificationAllowed.value,
        );
      }
    }

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
    populateData();
    InAppUpdateService.checkForUpdate(context);
    NotificationInterfaceHandler.initateListeners(context);

    if (widget.initalScreenIndex != null &&
        _selectedIndex >= 0 &&
        _selectedIndex < bottomNavigationButtonText.length) {
      _selectedIndex = widget.initalScreenIndex!;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;

      context.read<FriendCubit>().addFriendFromCache();
      final state = context.read<NotificationBloc>().state;

      if (state is! NotificationFetchSuccess) {
        context.read<NotificationBloc>().add(NotificationFetch());
      }
    }
  }

  void _onItemTapped(int index) {
    if (mounted) {
      _selectedIndex = index;
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

  Future<void> _drawerHandler(int index) async {
    switch (drawerTitle[index]) {
      case "Get Notified":
        {
          final notificationStatus =
              await context.push(RouterConstants.notificationPage) as bool?;

          if (notificationStatus != null) {
            isNotificationAllowed.value = notificationStatus;
          }
          break;
        }
      case "Preference":
        {
          context.push(RouterConstants.preferencePage);
          break;
        }
      case "Share":
        {
          SharePlus.instance.share(ShareParams(text: getShareMessage()));
          break;
        }
      case "Rate Us":
        {
          inAppReview.openStoreListing();
          break;
        }
      case "About Us":
        {
          context.push(RouterConstants.aboutUsPage);
          break;
        }
      case "Profile":
        {
          context.push(RouterConstants.profileRouteName);
          break;
        }
      case "Log Out":
        {
          context.read<AuthBloc>().add(AuthLogoutRequested());
          break;
        }
      default:
    }
  }

  Widget _drawerWidget() {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).drawerTheme.backgroundColor,
            ),
            currentAccountPicture: imageWidgetForCachedNetworkImage(
              _loggedInUser.profileImage,
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
          ...List.generate(drawerTitle.length, (index) {
            return ValueListenableBuilder(
              valueListenable: isNotificationAllowed,
              builder: (BuildContext context, _, _) {
                if (kIsWeb &&
                    (drawerTitle[index] == "Get Notified" ||
                        drawerTitle[index] == "Rate Us" ||
                        drawerTitle[index] == "Share")) {
                  return SizedBox.shrink();
                }
                if (drawerTitle[index] == "Get Notified" &&
                    isNotificationAllowed.value) {
                  return SizedBox.shrink();
                }
                return ListTile(
                  onTap: () {
                    _drawerHandler(index);
                  },
                  leading: Icon(
                    drawerIcon[index],
                    color: Colors.white,
                    size: 22,
                  ),
                  title: Text(
                    drawerTitle[index],
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  trailing: Visibility(
                    visible: index == -1,
                    child: Container(
                      width: 55,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.white60),
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

  Widget _notificationWithDot(int index) {
    if (bottomNavigationButtonText[index] == "Notification") {
      return Stack(
        children: [
          Consumer<NotificationBloc>(
            builder: (context, notificationBloc, child) {
              final state = notificationBloc.state;
              if (state is NotificationFetchSuccess && state.data.isNotEmpty) {
                return child!;
              } else {
                return SizedBox.shrink();
              }
            },
            child: Positioned(top: 0, right: 0, child: dot()),
          ),
          Icon(bottomNavigationButtonIcon[index]),
        ],
      );
    } else {
      return Icon(bottomNavigationButtonIcon[index]);
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
            bottomNavigationButtonText.length,
            (index) => BottomNavigationBarItem(
              icon: _notificationWithDot(index),
              label: bottomNavigationButtonText[index],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomNavigatorBodyHandler(int index) {
    switch (index) {
      case 1:
        return QuickSplitDashboardScreen(isSearchEnabled: _isSearchEnabled);
      case 2:
        return PersonalExpenseDashboardScreen(
          isSearchEnabled: _isSearchEnabled,
        );
      case 3:
        return LendenDashboardScreen(isSearchEnabled: _isSearchEnabled);
      case 4:
        return NotificationScreen(isSearchEnabled: _isSearchEnabled);
      default:
        return RoomDashboardScreen(isSearchEnabled: _isSearchEnabled);
    }
  }

  PreferredSizeWidget? _bottomNavigatorAppBarHandler(int index) {
    List<Widget> appBarActions = [];

    if (index <= 4) {
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
                appBar: _bottomNavigatorAppBarHandler(_selectedIndex),
                body: _bottomNavigatorBodyHandler(_selectedIndex),
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
