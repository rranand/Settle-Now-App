import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/card/login_activity_card.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class LoginActivityScreen extends StatefulWidget {
  const LoginActivityScreen({super.key});

  @override
  State<LoginActivityScreen> createState() => _LoginActivityScreenState();
}

class _LoginActivityScreenState extends State<LoginActivityScreen> {
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
      appBar: AppBar(
        title: Text("Login Activity"),
        titleSpacing: _mainScreenPadding.left,
        leading: appBarBackButton(context),
      ),
      body: ListView.separated(
        padding: _mainScreenPadding.add(
          EdgeInsets.only(
            top: UiConstant.spaceBetweenSection,
            bottom: 2 * UiConstant.spaceBetweenSection,
          ),
        ),
        itemBuilder:
            (context, index) => LoginActivityCard(
              deviceType: (index % 2 == 0 ? "Mobile" : "Web"),
            ),
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(height: .5 * UiConstant.spaceBetweenSection);
        },
        itemCount: 10,
      ),
    );
  }
}
