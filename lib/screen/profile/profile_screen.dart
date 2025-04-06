import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  final List<String> _popMenuTitle = ["Delete My Account"];

  void _popMenuButtonHandler(int index) {}

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
        actions: [
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
          SizedBox(width: _mainScreenPadding.right),
        ],
      ),

      body: Padding(
        padding: _mainScreenPadding.add(
          EdgeInsets.only(
            top: UiConstant.spaceBetweenSection,
            bottom: 2 * UiConstant.spaceBetweenSection,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Card(
                elevation: 4,
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      overlapUserImageWidget(
                        context,
                        [UiConstant.memberAvatars.first],
                        2,
                        imageRadius: 110,
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
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(height: 200, width: 200, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
