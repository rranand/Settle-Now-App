import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/bloc/add_to_personal_expense/add_to_personal_expense_bloc.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/lenden/dashboard/lenden_dashboard_bloc.dart';
import 'package:settlenow_v2/bloc/lenden/room/lenden_room_bloc.dart';
import 'package:settlenow_v2/bloc/notification/notification_bloc.dart';
import 'package:settlenow_v2/bloc/notification_action/notification_action_bloc.dart';
import 'package:settlenow_v2/bloc/personal_expense/dashboard/personal_expense_dashboard_bloc.dart';
import 'package:settlenow_v2/bloc/personal_expense/monthly_expense/personal_expense_bloc.dart';
import 'package:settlenow_v2/bloc/quicksplit/quicksplit_bloc.dart';
import 'package:settlenow_v2/bloc/room/dashboard/room_dashboard_bloc.dart';
import 'package:settlenow_v2/bloc/room/each_room/room_bloc.dart';
import 'package:settlenow_v2/constant/home_ui_constant.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/cubit/lenden/create_room/create_room_cubit.dart';
import 'package:settlenow_v2/cubit/new_transaction/new_transaction_cubit.dart';
import 'package:settlenow_v2/cubit/room/create_join_room/create_join_room_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_close/room_close_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_close_request/room_close_request_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_info/room_info_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_settle/room_settle_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_settle_upsert/room_settle_upsert_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_user/room_user_cubit.dart';
import 'package:settlenow_v2/cubit/user/friend/friend_cubit.dart';
import 'package:settlenow_v2/cubit/user/user_login_activity/user_login_activity_cubit.dart';
import 'package:settlenow_v2/cubit/user/user_update_profile/user_update_profile_cubit.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/screen/dashboard/lenden/lenden_dashboard_screen.dart';
import 'package:settlenow_v2/screen/dashboard/notification/notification_screen.dart';
import 'package:settlenow_v2/screen/dashboard/personal_expense/personal_expense_dashboard_screen.dart';
import 'package:settlenow_v2/screen/dashboard/quicksplit/quick_split_dashboard_screen.dart';
import 'package:settlenow_v2/screen/dashboard/room/room_dashboard_screen.dart';
import 'package:settlenow_v2/util/card/loading_card.dart';
import 'package:settlenow_v2/util/widgets/image_widget.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final GlobalKey<ScaffoldState> _homeScreenkey =
      GlobalKey<ScaffoldState>();
  final ValueNotifier<bool> _isSearchEnabled = ValueNotifier(false);
  UserModel _loggedInUser = UserModel.empty();
  int _selectedIndex = 0;
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainScreenPadding = context.watch<ScreenSizeProvider>().getPadding;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
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
            "Version 1.0.0",
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
                visible: index == 3 || index == 4,
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

  void resetAllBlocs() {
    context.read<AddToPersonalExpenseBloc>().add(AddToPersonalExpenseReset());
    context.read<LendenDashboardBloc>().add(LendenDashboardReset());
    context.read<LendenRoomBloc>().add(LendenRoomReset());
    context.read<NotificationBloc>().add(NotificationReset());
    context.read<NotificationActionBloc>().add(NotificationActionReset());
    context.read<PersonalExpenseDashboardBloc>().add(
      PersonalExpenseDashboardReset(),
    );
    context.read<PersonalMonthlyExpenseBloc>().add(
      PersonalMonthlyExpenseReset(),
    );
    context.read<QuicksplitBloc>().add(QuicksplitReset());
    context.read<RoomDashboardBloc>().add(RoomDashboardReset());
    context.read<RoomBloc>().add(RoomBlocReset());
    context.read<CreateRoomCubit>().reset();
    context.read<NewTransactionCubit>().reset();
    context.read<FriendCubit>().reset();
    context.read<UserLoginActivityCubit>().reset();
    context.read<UserUpdateProfileCubit>().reset();
    context.read<CreateJoinRoomCubit>().reset();
    context.read<RoomCloseCubit>().reset();
    context.read<RoomCloseRequestCubit>().reset();
    context.read<RoomInfoCubit>().reset();
    context.read<RoomSettleCubit>().reset();
    context.read<RoomSettleUpsertCubit>().reset();
    context.read<RoomUserCubit>().reset();
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
          resetAllBlocs();
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
