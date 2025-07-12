import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/lenden/room/lenden_room_bloc.dart';
import 'package:settlenow_v2/constant/gradient_color_constant.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/model/lenden_room_model.dart';
import 'package:settlenow_v2/model/lenden_user_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/card/lenden_expense_card.dart';
import 'package:settlenow_v2/util/card/lenden_summary_card.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/gradient_widget.dart';
import 'package:settlenow_v2/util/widgets/image_widget.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class LendenExpenseScreen extends StatefulWidget {
  final String id;
  final String? roomName;

  const LendenExpenseScreen({super.key, required this.id, this.roomName});

  @override
  State<LendenExpenseScreen> createState() => _LendenExpenseScreenState();
}

class _LendenExpenseScreenState extends State<LendenExpenseScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  UserModel _loggedInUser = UserModel.empty();

  void _blocListenerHandler(BuildContext context, LendenRoomState state) {
    if (state is LendenRoomFailure) {
      showNormalSnackBar(context, state.error);
    }
  }

  List<LendenTransactionModel> generateShimmerData() {
    return List.generate(11, (i) {
      LendenTransactionModel tempData = LendenTransactionModel.empty();
      if (i % 2 == 0) {
        tempData.createdBy.id = _loggedInUser.id;
      }
      return tempData;
    });
  }

  void _closeRoomPopupDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Close Room"),
          content: Text("Are You Sure?", style: TextStyle(fontSize: 18)),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                context.pop();
                context.read<LendenRoomBloc>().add(
                  LendenCloseRoom(
                    authToken: _loggedInUser.authToken,
                    uid: _loggedInUser.id,
                  ),
                );
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context, List<LendenUserModel> oldUsers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        return BlocBuilder<LendenRoomBloc, LendenRoomState>(
          builder: (context, state) {
            bool showAddPerson = false;
            List<LendenUserModel> users = [];
            if (state is LendenRoomFetchSuccess) {
              users = state.roomData.users;
              if (state.roomData.status == "Open" && users.length == 1) {
                showAddPerson = true;
              }
            } else {
              users = oldUsers;
            }
            return Padding(
              padding: const EdgeInsets.all(
                16.0,
              ).add(EdgeInsets.only(bottom: keyboardHeight)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      height: 4,
                      width: 60,
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Users",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Visibility(
                        visible: showAddPerson,
                        child: IconButton(
                          icon: Icon(Iconsax.user_add),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      children: List.generate(users.length, (index) {
                        return ListTile(
                          leading: imageWidgetForCachedNetworkImage(
                            users[index].profileImage,
                            width: 45,
                            height: 45,
                            boxShape: BoxShape.circle,
                          ),
                          title: Text(users[index].name),
                          subtitle: Text(
                            users[index].isClosed ? "Closed" : "Open",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing:
                              _loggedInUser.id == users[index].id &&
                                      !users[index].isClosed
                                  ? IconButton(
                                    icon: Icon(Iconsax.unlock),
                                    onPressed: () => _closeRoomPopupDialog(),
                                  )
                                  : null,
                        );
                      }),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: InkWell(
                      onTap: () => context.pop(),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * .9,
                        child: GradientWidget(
                          text: "Close",
                          gradientColors:
                              GradientColorConstant.coolIndigoToBlue,
                          textSize: 14,
                          textColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _loadingScreen(EdgeInsets paddingInsets) {
    List<LendenTransactionModel> lendenTransactionData = generateShimmerData();
    return Scaffold(
      appBar: AppBar(
        title: CustomShimmerEffect.textWidget(width: 180, fontSize: 20),
        titleSpacing: _mainScreenPadding.left,
        centerTitle: false,
        leading: appBarBackButton(context),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: paddingInsets.add(
              EdgeInsets.only(bottom: UiConstant.spaceBetweenSection),
            ),
            sliver: SliverToBoxAdapter(
              child: CustomShimmerEffect.placeHolderShimmerEffect(
                Container(
                  height: 95,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: _mainScreenPadding,
            sliver: SliverList.builder(
              itemCount: lendenTransactionData.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom:
                        index == lendenTransactionData.length - 1
                            ? UiConstant.spaceAtBottom
                            : 0,
                  ),
                  child: LendenExpenseCard(
                    lendenID: widget.id,
                    data: lendenTransactionData[index],
                    loggedInUser: _loggedInUser,
                    isEditable: false,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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

      final state = context.read<LendenRoomBloc>().state;

      if (!(state is LendenRoomFetchSuccess && state.id == widget.id)) {
        context.read<LendenRoomBloc>().add(
          LendenRoomFetch(id: widget.id, authToken: _loggedInUser.authToken),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= UiConstant.maxWidth;
    EdgeInsets paddingInsets = _mainScreenPadding;
    if (!isWide) {
      paddingInsets = EdgeInsets.symmetric(horizontal: 8);
    }
    return BlocConsumer<LendenRoomBloc, LendenRoomState>(
      listener: _blocListenerHandler,
      builder: (context, state) {
        if (state is LendenRoomFetchSuccess) {
          List<LendenTransactionModel> lendenTransactionData = state.data;
          LendenUserModel loggedInUserData = state.roomData.users.firstWhere(
            (ele) => ele.id == _loggedInUser.id,
          );

          return Scaffold(
            appBar: AppBar(
              title: Text(state.roomData.roomName),
              titleSpacing: _mainScreenPadding.left,
              centerTitle: false,
              leading: appBarBackButton(context),
              actions: appBarActionButton(context, [
                IconButton(
                  onPressed:
                      () => _showBottomSheet(context, state.roomData.users),
                  icon: Icon(Iconsax.profile_2user),
                ),
              ]),
            ),
            body:
                lendenTransactionData.isEmpty
                    ? noRecordFoundWidget("No Transaction Found", context)
                    : CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: paddingInsets.add(
                            EdgeInsets.only(
                              bottom: UiConstant.spaceBetweenSection,
                            ),
                          ),
                          sliver: SliverToBoxAdapter(
                            child: LendenSummaryCard(
                              data: lendenTransactionData,
                              loggedInUser: _loggedInUser,
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: _mainScreenPadding,
                          sliver: SliverList.builder(
                            itemCount: lendenTransactionData.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      index == lendenTransactionData.length - 1
                                          ? UiConstant.spaceAtBottom
                                          : 0,
                                ),
                                child: LendenExpenseCard(
                                  lendenID: widget.id,
                                  data: lendenTransactionData[index],
                                  loggedInUser: _loggedInUser,
                                  isEditable: !loggedInUserData.isClosed,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            floatingActionButton:
                loggedInUserData.isClosed
                    ? null
                    : CustomButton.customFloatingButton(Iconsax.add, () {
                      context.push(
                        "${RouterConstants.lendenRouteName}/${widget.id}${RouterConstants.lendenAddExpenseRouteName}",
                      );
                    }),
          );
        } else {
          return _loadingScreen(paddingInsets);
        }
      },
    );
  }
}
