import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/Notification/notification_interface_handler.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/notification/notification_bloc.dart';
import 'package:settlenow_v2/constant/home_ui_constant.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/screen/dashboard/lenden/lenden_dashboard_screen.dart';
import 'package:settlenow_v2/screen/dashboard/notification/notification_screen.dart';
import 'package:settlenow_v2/screen/dashboard/personal_expense/personal_expense_dashboard_screen.dart';
import 'package:settlenow_v2/screen/dashboard/quicksplit/quick_split_dashboard_screen.dart';
import 'package:settlenow_v2/screen/dashboard/room/room_dashboard_screen.dart';
import 'package:settlenow_v2/util/card/loading_card.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';
import 'package:settlenow_v2/util/functions/in_app_update_service.dart';
import 'package:settlenow_v2/util/handler/platform_service.dart';
import 'package:settlenow_v2/util/widgets/image_widget.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final InAppReview inAppReview = InAppReview.instance;
  static final GlobalKey<ScaffoldState> _homeScreenkey =
      GlobalKey<ScaffoldState>();
  final ValueNotifier<bool> _isSearchEnabled = ValueNotifier(false);
  UserModel _loggedInUser = UserModel.empty();
  int _selectedIndex = 0;
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  String appVersion = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainScreenPadding = context.watch<ScreenSizeProvider>().getPadding;
    if (mounted) {
      setState(() {});
    }
  }

  void populateData() async {
    appVersion = await getAppVersion();
  }

  @override
  void initState() {
    super.initState();
    populateData();
    InAppUpdateService.checkForUpdate();

    NotificationInterfaceHandler.initateListeners(context);
    NotificationInterfaceHandler.initializeChannels();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;

      final state = context.read<NotificationBloc>().state;

      if (state is! NotificationFetchSuccess) {
        context.read<NotificationBloc>().add(
          NotificationFetch(authToken: _loggedInUser.authToken),
        );
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
          Text(
            "Version $appVersion",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.white),
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

  _drawerHandler(int index) {
    switch (drawerTitle[index]) {
      case "Get Notified":
        {
          AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
            if (!isAllowed) {
              AwesomeNotifications().requestPermissionToSendNotifications();
            }
          });
        }
      case "Share":
        SharePlus.instance.share(
          ShareParams(
            text:
                "Settle Now\n\nSettle Now helps to split daily bills within your friends, roommates, flatmates, etc, and eliminate the stressing about 'who owes who.'\n\nhttps://play.google.com/store/apps/details?id=com.rohit.settlenow",
          ),
        );
      case "Rate Us":
        {
          AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: 10,
              channelKey: 'roomID',
              actionType: ActionType.Default,
              title: 'Hello World!',
              body: 'This is my first notification!',
            ),
          );
          //inAppReview.openStoreListing();
        }
      case "About Us":
        context.push(RouterConstants.aboutUsPage);
      case "Profile":
        context.push(RouterConstants.profileRouteName);
      case "Log Out":
        context.read<AuthBloc>().add(AuthLogoutRequested());
      default:
    }
  }

  Widget _drawerWidget() {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: imageWidgetForCachedNetworkImage(
              _loggedInUser.profileImage,
              boxShape: BoxShape.circle,
            ),
            accountName: Text(_loggedInUser.name),
            accountEmail: Text(_loggedInUser.email),
          ),
          ...List.generate(drawerTitle.length, (index) {
            return ListTile(
              onTap: () {
                _drawerHandler(index);
              },
              leading: Icon(drawerIcon[index], color: Colors.white, size: 22),
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
          selectedItemColor: Colors.deepPurpleAccent,
          unselectedItemColor: Colors.black54,
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

  Widget _bottomNavigatorBodyHandler(index) {
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

  PreferredSizeWidget? _bottomNavigatorAppBarHandler(index) {
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
          return Scaffold(
            appBar: AppBar(backgroundColor: Colors.transparent),
            body: Scaffold(
              body: Center(child: Text("Error Page: ${state.error}")),
            ),
          );
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
  }
}
