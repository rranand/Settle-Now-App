import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
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
            ListTile(
              onTap: () {},
              leading: Icon(
                Iconsax.profile_2user,
                color: Colors.white,
                size: 22,
              ),
              title: Text(
                "Profile",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(Iconsax.bank, color: Colors.white, size: 22),
              title: Text(
                "Bank Transactions",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              trailing: Container(
                width: 55,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    "Beta",
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ),
              ),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(
                Iconsax.calendar_tick,
                color: Colors.white,
                size: 22,
              ),
              title: Text(
                "Reminder",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              trailing: Container(
                width: 55,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    "Beta",
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ),
              ),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(Iconsax.import, color: Colors.white, size: 22),
              title: Text(
                "Import Contacts",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(
                Icons.notifications_active_outlined,
                color: Colors.white,
                size: 22,
              ),
              title: Text(
                "Get Notified",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            ListTile(
              leading: Icon(Iconsax.sun_1, color: Colors.white, size: 22),
              title: Text(
                "Theme",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              trailing: IconButton(
                onPressed: () {},
                icon: Icon(Icons.brightness_2, color: Colors.black87, size: 22),
              ),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(Iconsax.share, color: Colors.white, size: 22),
              title: Text(
                "Share",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(
                Iconsax.archive_book,
                color: Colors.white,
                size: 22,
              ),
              title: Text(
                "About Us",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(Iconsax.support, color: Colors.white, size: 22),
              title: Text(
                "Contact Us",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(
                Icons.star_border_rounded,
                color: Colors.white,
                size: 22,
              ),
              title: Text(
                "Rate Us",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            ListTile(
              onTap: () async {},
              leading: Icon(Iconsax.logout, color: Colors.white, size: 22),
              title: Text(
                "Log Out",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
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
