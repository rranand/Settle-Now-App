import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/constant/home_ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/screen/dashboard/lenden/lenden_dashboard_screen.dart';
import 'package:settlenow_v2/screen/dashboard/personal_expense/personal_expense_dashboard_screen.dart';
import 'package:settlenow_v2/screen/dashboard/quicksplit/quick_split_dashboard_screen.dart';
import 'package:settlenow_v2/screen/dashboard/room/room_dashboard_screen.dart';
import 'package:settlenow_v2/util/widgets/image_widget.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _homeScreenkey = GlobalKey();
  final ValueNotifier<bool> _isSearchEnabled = ValueNotifier(false);
  int _selectedIndex = 3;
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainScreenPadding = context.watch<ScreenSizeProvider>().getPadding;
    if (mounted) {
      setState(() {});
    }
  }

  void _onItemTapped(int index) {
    if (mounted) {
      _selectedIndex = index;
      _isSearchEnabled.value = false;
      setState(() {});
    }
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
    switch (index) {
      case 0:
        context.push(RouterConstants.profileRouteName);
      default:
    }
  }

  Widget _drawerWidget() {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: imageWidgetForCachedNetworkImage(
              "https://fastly.picsum.photos/id/237/200/300.jpg?hmac=TmmQSbShHz9CdQm0NkEjx1Dyh_Y984R9LpNrpvH2D_U",
              boxShape: BoxShape.circle,
            ),
            accountName: Text("Rohit Anand"),
            accountEmail: Text("rrohitanand3336@gmail.com"),
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
              icon: Icon(bottomNavigationButtonIcon[index]),
              label: bottomNavigationButtonText[index],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomNavigatorBodyHandler(index) {
    switch (index) {
      case 0:
        return RoomDashboardScreen(isSearchEnabled: _isSearchEnabled);
      case 1:
        return QuickSplitDashboardScreen(isSearchEnabled: _isSearchEnabled);
      case 2:
        return PersonalExpenseDashboardScreen(
          isSearchEnabled: _isSearchEnabled,
        );
      case 3:
        return LendenDashboardScreen(isSearchEnabled: _isSearchEnabled);
      default:
        return Placeholder();
    }
  }

  PreferredSizeWidget? _bottomNavigatorAppBarHandler(index) {
    List<Widget> appBarActions = [];

    switch (index) {
      case 0:
        appBarActions = [
          InkWell(
            child: Icon(Icons.search),
            onTap: () {
              _isSearchEnabled.value = !_isSearchEnabled.value;
            },
          ),
        ];
        break;
      case 1:
        appBarActions = [
          InkWell(
            child: Icon(Icons.search),
            onTap: () {
              _isSearchEnabled.value = !_isSearchEnabled.value;
            },
          ),
        ];
        break;
      case 2:
        appBarActions = [
          InkWell(
            child: Icon(Icons.search),
            onTap: () {
              _isSearchEnabled.value = !_isSearchEnabled.value;
            },
          ),
        ];
        break;
      case 3:
        appBarActions = [
          InkWell(
            child: Icon(Icons.search),
            onTap: () {
              _isSearchEnabled.value = !_isSearchEnabled.value;
            },
          ),
        ];
        break;
      default:
        appBarActions = [];
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
      actions: appBarActionButton(context, appBarActions),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _homeScreenkey,
      appBar: _bottomNavigatorAppBarHandler(_selectedIndex),
      body: _bottomNavigatorBodyHandler(_selectedIndex),
      bottomNavigationBar: _bottomNavigationBarWidget(),
      drawer: _drawerWidget(),
    );
  }
}
