import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
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
  UserModel _loggedInUser = UserModel.empty();
  final List<String> _popMenuTitle = ["Delete My Account"];
  final List<String> _accountSectionTitle = ["Edit Profile", "Login Activity"];
  final List<IconData> _accountSectionIconData = [
    Iconsax.edit_copy,
    Iconsax.monitor_mobbile_copy,
  ];

  void _popMenuButtonHandler(int index) async {
    switch (_popMenuTitle[index]) {
      case "Delete My Account":
        {
          final AuthBloc authBloc = context.read<AuthBloc>();
          final ScaffoldMessengerState scaffoldMessengerState =
              ScaffoldMessenger.of(context);
          bool isDeletePermitted = await deleteAccountDialog(
            context,
            _loggedInUser.email,
          );
          if (context.mounted && isDeletePermitted) {
            authBloc.add(AuthProfileDeleteRequested(scaffoldMessengerState));
          }
        }
      default:
        {}
    }
  }

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
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        titleSpacing: _mainScreenPadding.left,
        leading: appBarBackButton(context),
        actions: appBarActionButton(
          context,
          _loggedInUser.hasData
              ? [
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
              ]
              : [],
        ),
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
                    _loggedInUser.hasData
                        ? overlapUserImageWidget(
                          context,
                          [_loggedInUser],
                          1,
                          imageRadius: 100,
                        )
                        : CustomShimmerEffect.overlapImageWidget(
                          noOfImages: 1,
                          imageRadius: 100,
                        ),
                    SizedBox(width: UiConstant.spaceBetweenRowSection),
                    _loggedInUser.hasData
                        ? Text.rich(
                          TextSpan(
                            text: _loggedInUser.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                            children: [
                              TextSpan(
                                text: "\n",
                                children: [
                                  TextSpan(
                                    text: _loggedInUser.email,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: kDefaultFontSize,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomShimmerEffect.textWidget(
                              fontSize: 24,
                              width: 150,
                            ),
                            SizedBox(height: 4),
                            CustomShimmerEffect.textWidget(width: 200),
                          ],
                        ),
                  ],
                ),
              ),
            ),
            SizedBox(height: UiConstant.spaceBetweenSection),
            _loggedInUser.hasData
                ? Card(
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
                              trailing: Icon(Iconsax.arrow_right_3_copy),
                              onTap: () {
                                _accountSectionButtonHandler(index);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : CustomShimmerEffect.placeHolderShimmerEffect(
                  Container(
                    height: 190,
                    padding: _cardPadding,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                  child:
                      _loggedInUser.hasData
                          ? Text(
                            "Member Since ${convertInDateFormat(_loggedInUser.createdOn)}",
                            style: TextStyle(color: Colors.grey),
                          )
                          : CustomShimmerEffect.textWidget(width: 250),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
