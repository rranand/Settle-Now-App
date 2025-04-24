import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  final EdgeInsets _cardPadding = EdgeInsets.symmetric(
    vertical: 18.0,
    horizontal: 14,
  );
  final List<String> _popMenuTitle = ["Delete My Account"];
  final List<String> _accountSectionTitle = ["Edit Profile", "Login Activity"];
  final List<IconData> _accountSectionIconData = [
    Iconsax.edit,
    Iconsax.monitor_mobbile,
  ];

  void _popMenuButtonHandler(int index) {}

  void _accountSectionButtonHandler(int index) {
    switch (index) {
      case 0:
        {
          context.push(
            "${RouterConstants.profileRouteName}${RouterConstants.profileEditRouteName}",
          );
        }
        break;
      case 1:
        {
          context.push(
            "${RouterConstants.profileRouteName}${RouterConstants.loginActivityRouteName}",
          );
        }
        break;
      default:
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
      appBar: AppBar(
        title: Text("Profile"),
        titleSpacing: _mainScreenPadding.left,
        leading: appBarBackButton(context),
        actions: appBarActionButton(context, [
          PopupMenuButton<int>(
            icon: Icon(Icons.more_vert),
            onSelected: _popMenuButtonHandler,
            itemBuilder:
                (context) => List.generate(
                  _popMenuTitle.length,
                  (index) => PopupMenuItem(
                    value: index,
                    child: Text(_popMenuTitle[index]),
                  ),
                ),
          ),
        ]),
      ),
      body: SingleChildScrollView(
        padding: _mainScreenPadding.add(
          EdgeInsets.only(
            top: UiConstant.spaceBetweenSection,
            bottom: 2 * UiConstant.spaceBetweenSection,
          ),
        ),
        child: Column(
          children: [
            Card(
              elevation: UiConstant.cardElevation,
              color: Colors.white,
              child: Padding(
                padding: _cardPadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    overlapUserImageWidget(
                      context,
                      [UiConstant.users.first],
                      1,
                      imageRadius: 100,
                    ),
                    SizedBox(width: UiConstant.spaceBetweenRowSection),
                    Text.rich(
                      TextSpan(
                        text: "Rohit Anand",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                        children: [
                          TextSpan(
                            text: "\n",
                            children: [
                              TextSpan(
                                text: "emailID@gmail.com",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: kDefaultFontSize,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: UiConstant.spaceBetweenSection),
            Card(
              elevation: UiConstant.cardElevation,
              color: Colors.white,
              child: Padding(
                padding: _cardPadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Account",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...List.generate(
                      _accountSectionTitle.length,
                      (index) => Padding(
                        padding: EdgeInsets.only(
                          top: UiConstant.spaceBetweenSection,
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: colouredIcon(
                            Icon(_accountSectionIconData[index]),
                            UiConstant.colorsWithShade100[index],
                          ),
                          title: Text(_accountSectionTitle[index]),
                          trailing: Icon(Iconsax.arrow_right_34),
                          onTap: () {
                            _accountSectionButtonHandler(index);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: UiConstant.spaceBetweenSection),
            Card(
              elevation: UiConstant.cardElevation,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 14),
                child: Center(
                  child: Text(
                    "Member Since March 31, 2022",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
