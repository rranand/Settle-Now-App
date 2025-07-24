import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/card/loading_card.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';
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

  void _popMenuButtonHandler(int index) {
    switch (_popMenuTitle[index]) {
      case "Delete My Account":
        {
          context.read<AuthBloc>().add(AuthProfileDeleteRequested());
        }
      default:
        {}
    }
  }

  void _blocListenerHandler(BuildContext context, AuthState state) {
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
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: _blocListenerHandler,
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
        }
        UserModel userData = UserModel.empty();

        if (state is AuthLoginSuccess) {
          userData = state.userData;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text("Profile"),
            titleSpacing: _mainScreenPadding.left,
            leading: appBarBackButton(context),
            actions: appBarActionButton(
              context,
              userData.hasData
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
                        userData.hasData
                            ? overlapUserImageWidget(
                              context,
                              [userData],
                              1,
                              imageRadius: 100,
                            )
                            : CustomShimmerEffect.overlapImageWidget(
                              noOfImages: 1,
                              imageRadius: 100,
                            ),
                        SizedBox(width: UiConstant.spaceBetweenRowSection),
                        userData.hasData
                            ? Text.rich(
                              TextSpan(
                                text: userData.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                                children: [
                                  TextSpan(
                                    text: "\n",
                                    children: [
                                      TextSpan(
                                        text: userData.email,
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
                userData.hasData
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
                    padding: EdgeInsets.symmetric(
                      vertical: 14.0,
                      horizontal: 14,
                    ),
                    child: Center(
                      child:
                          userData.hasData
                              ? Text(
                                "Member Since ${convertInDateFormat(userData.createdOn)}",
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
      },
    );
  }
}
