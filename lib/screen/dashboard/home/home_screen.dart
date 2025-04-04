import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/constant/home_ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/screen/bank_transactions/bank_transaction_screen.dart';
import 'package:settlenow_v2/util/widgets/image_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (mounted) {
      _selectedIndex = index;
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainScreenPadding = context.watch<ScreenSizeProvider>().getPadding;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settle Now")),
      body: Padding(
        padding: _mainScreenPadding,
        child: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return BankTranactionScreen();
          },
          itemCount: 10,
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(height: 8);
          },
        ),
      ),
      bottomNavigationBar: Container(
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
      ),
      drawer: Drawer(
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
                onTap: () {},
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
            ListTile(
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
            ),
          ],
        ),
      ),
    );
  }
}
