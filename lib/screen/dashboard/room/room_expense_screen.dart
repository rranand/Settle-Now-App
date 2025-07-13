import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/room/each_room/room_bloc.dart';
import 'package:settlenow_v2/constant/gradient_color_constant.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/cubit/room/create_join_room/create_join_room_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_close/room_close_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_close_request/room_close_request_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_info/room_info_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_settle/room_settle_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_user/room_user_cubit.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/model/room_user_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/screen/dashboard/room/sub_section/room_analysis_screen.dart';
import 'package:settlenow_v2/screen/dashboard/room/sub_section/room_settle_screen.dart';
import 'package:settlenow_v2/screen/dashboard/room/sub_section/room_transaction_screen.dart';
import 'package:settlenow_v2/screen/dashboard/room/sub_section/room_user_screen.dart';
import 'package:settlenow_v2/util/custom/custom_gesture_detector.dart';
import 'package:settlenow_v2/util/enum/transaction_type.dart';
import 'package:settlenow_v2/util/widgets/navbar_widget.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class RoomExpenseScreen extends StatefulWidget {
  final String id;
  const RoomExpenseScreen({super.key, required this.id});

  @override
  State<RoomExpenseScreen> createState() => _RoomExpenseScreenState();
}

class _RoomExpenseScreenState extends State<RoomExpenseScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  final double _navBarHeight = 60;
  final ValueNotifier<int> _navbarSelectedIndex = ValueNotifier(0);
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  UserModel _loggedInUser = UserModel.empty();
  late final StreamSubscription roomCloseRequestSubscription;
  late final StreamSubscription roomCloseSubscription;
  String currentRoute = "";

  final List<String> _navBarTitles = [
    "Transactions",
    "Users",
    "Analysis",
    "Settle",
  ];

  Widget _summaryBox(String title, String value) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.white70)),
        Text(
          value,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _navBarHandler(int index) {
    switch (index) {
      case 1:
        return RoomUserScreen();
      case 2:
        return RoomAnalysisScreen();
      case 3:
        return RoomSettleScreen(roomID: widget.id);
      default:
        return RoomTransactionScreen(roomID: widget.id);
    }
  }

  void _resetCubit() {
    final RoomSettleState roomSettleState =
        context.watch<RoomSettleCubit>().state;

    if (roomSettleState is RoomSettleSuccess &&
        roomSettleState.id != widget.id) {
      context.read<RoomSettleCubit>().reset();
    }

    final RoomState roomState = context.watch<RoomBloc>().state;
    if (roomState is RoomFetchSuccess && roomState.id != widget.id) {
      context.read<RoomBloc>().add(RoomBlocReset());
    }

    final RoomUserState roomUserState = context.watch<RoomUserCubit>().state;
    if (roomUserState is RoomUserSuccess && roomUserState.id != widget.id) {
      context.read<RoomUserCubit>().reset();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainScreenPadding = context.watch<ScreenSizeProvider>().getPadding;
    _resetCubit();
    final RoomInfoState roomInfoState = context.watch<RoomInfoCubit>().state;
    if (roomInfoState is RoomInfoSuccess) {
      final RoomSettleState roomSettleState =
          context.watch<RoomSettleCubit>().state;
      if (roomSettleState is! RoomSettleSuccess ||
          (roomSettleState.id != widget.id)) {
        context.read<RoomSettleCubit>().fetchData(
          widget.id,
          _loggedInUser.authToken,
          roomInfoState.data.users,
        );
      }

      final RoomState roomState = context.watch<RoomBloc>().state;
      if (roomState is! RoomFetchSuccess || (roomState.id != widget.id)) {
        context.read<RoomBloc>().add(
          RoomFetch(
            id: widget.id,
            authToken: _loggedInUser.authToken,
            users: roomInfoState.data.users,
          ),
        );
      }

      final RoomUserState roomUserState = context.watch<RoomUserCubit>().state;

      if (roomSettleState is RoomSettleSuccess &&
          roomSettleState.id == widget.id &&
          roomState is RoomFetchSuccess &&
          roomState.id == widget.id &&
          (roomUserState is! RoomUserSuccess ||
              roomUserState.id != widget.id)) {
        context.read<RoomUserCubit>().fetchData(
          roomInfoState.data.id,
          roomInfoState.data.users,
          roomState.data,
          roomSettleState.data,
        );
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Widget _roomSummaryCard() {
    return BlocBuilder<RoomUserCubit, RoomUserState>(
      builder: (context, state) {
        if (state is RoomUserSuccess) {
          RoomUserModel data = RoomUserModel.empty();
          double totalSpent = 0;
          for (int i = 0; i < state.data.length; i++) {
            if (_loggedInUser.id == state.data[i].user.id) {
              data = state.data[i];
            }
            totalSpent += state.data[i].contribution;
          }
          double balance = data.contribution - data.spent + data.settle;
          balance = (balance.abs() < 1e-2) ? 0 : balance;

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: GradientColorConstant.greenToTeal,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Room Overview",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _summaryBox(
                        "Total Spent",
                        formatCurrency(totalSpent, context),
                      ),
                      _summaryBox(
                        "You Gave",
                        formatCurrency(data.contribution, context),
                      ),
                      _summaryBox(
                        "Balance",
                        "${balance < 0 ? "" : "+"}${formatCurrency(balance, context)}",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          return CustomShimmerEffect.placeHolderShimmerEffect(
            Container(
              padding: EdgeInsets.all(16),
              height: 108,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> onRefresh() async {
    if (!_loggedInUser.hasData) {
      showNormalSnackBar(context, "Please re-login...Session expired!");
      return;
    }

    final RoomInfoState roomInfoState = context.read<RoomInfoCubit>().state;
    if (roomInfoState is RoomInfoSuccess) {
      switch (_navbarSelectedIndex.value) {
        case 0 || 2:
          {
            context.read<RoomBloc>().add(
              RoomFetch(
                id: widget.id,
                authToken: _loggedInUser.authToken,
                users: roomInfoState.data.users,
              ),
            );
          }
        case 1:
          {
            final RoomSettleState roomSettleState =
                context.read<RoomSettleCubit>().state;
            final RoomState roomState = context.read<RoomBloc>().state;
            if (roomSettleState is RoomSettleSuccess &&
                roomState is RoomFetchSuccess) {
              context.read<RoomUserCubit>().fetchData(
                roomInfoState.data.id,
                roomInfoState.data.users,
                roomState.data,
                roomSettleState.data,
              );
            }
          }
        case 3:
          {
            context.read<RoomSettleCubit>().fetchData(
              widget.id,
              _loggedInUser.authToken,
              roomInfoState.data.users,
            );
          }
        default:
          {}
      }
    }
  }

  bool notificationPredicateHandler(ScrollNotification notification) {
    switch (_navbarSelectedIndex.value) {
      case 0 || 2:
        {
          final state = context.read<RoomBloc>().state;
          if (state is RoomFetchSuccess && state.data.isNotEmpty) {
            return notification.depth == 0;
          } else {
            return notification.depth == 1;
          }
        }
      case 1:
        {
          final state = context.read<RoomUserCubit>().state;
          if (state is RoomUserSuccess && state.data.isNotEmpty) {
            return notification.depth == 0;
          } else {
            return notification.depth == 1;
          }
        }
      case 3:
        {
          final state = context.read<RoomSettleCubit>().state;
          if (state is RoomSettleSuccess && state.data.isNotEmpty) {
            return notification.depth == 0;
          } else {
            return notification.depth == 1;
          }
        }
      default:
        return notification.depth == 0;
    }
  }

  @override
  void initState() {
    super.initState();
    currentRoute =
        GoRouter.of(context).routeInformationProvider.value.uri.toString();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;

      final state = context.read<RoomBloc>().state;

      if (!(state is RoomFetchSuccess && state.id == widget.id)) {
        context.read<RoomInfoCubit>().fetchData(
          widget.id,
          _loggedInUser.authToken,
        );
      }
    }

    roomCloseRequestSubscription = context
        .read<RoomCloseRequestCubit>()
        .stream
        .listen((state) {
          if (mounted) {
            if (state is RoomCloseRequestSuccess && widget.id == state.roomID) {
              if (state.retryCount > 1) {
                showNormalSnackBar(
                  context,
                  "Member Already Notified for Room Close",
                );
              } else {
                showNormalSnackBar(context, "Member Notified for Room Close");
              }
            } else if (state is RoomCloseRequestFailure &&
                widget.id == state.roomID) {
              showNormalSnackBar(context, state.error);
            }
          }
        });

    roomCloseSubscription = context.read<RoomCloseCubit>().stream.listen((
      state,
    ) {
      if (mounted) {
        if (state is RoomCloseSuccess && widget.id == state.roomID) {
          if (state.retryCount > 1) {
            showNormalSnackBar(context, "Room Already Closed");
          } else {
            showNormalSnackBar(context, "Room Closed Successfully");
          }
        } else if (state is RoomCloseFailure && widget.id == state.roomID) {
          showNormalSnackBar(context, state.error);
        }
      }
    });
  }

  @override
  void dispose() {
    roomCloseRequestSubscription.cancel();
    roomCloseSubscription.cancel();
    super.dispose();
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
                context.read<RoomCloseCubit>().closeRoom(
                  widget.id,
                  _loggedInUser.id,
                  _loggedInUser.authToken,
                );
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= UiConstant.maxWidth;
    EdgeInsets paddingInsets = _mainScreenPadding;
    if (!isWide) {
      paddingInsets = EdgeInsets.symmetric(horizontal: 8);
    }
    return BlocConsumer<RoomInfoCubit, RoomInfoState>(
      listener: (context, state) {
        if (state is RoomInfoFailure) {
          showNormalSnackBar(context, state.error);
        }
      },
      builder: (context, state) {
        bool isRoomActive = false;
        bool isLoaded = false;
        String roomName = "";
        RoomUserModel roomUserModel = RoomUserModel.empty();
        bool showSettleExpense = false;
        bool showCloseRoomRequest = false;

        if (state is RoomInfoSuccess) {
          isRoomActive = state.data.active;
          roomName = state.data.roomName;
          isLoaded = true;
          for (int i = 0; i < state.data.users.length; i++) {
            if (_loggedInUser.id == state.data.users[i].user.id) {
              roomUserModel = state.data.users[i];
            } else if (state.data.users[i].active) {
              showCloseRoomRequest = true;
            }
          }

          double unSettledAmount =
              roomUserModel.contribution -
              roomUserModel.spent +
              roomUserModel.settle;
          if (unSettledAmount.abs() >= 0.2) {
            showSettleExpense = true;
          }
        }

        return Scaffold(
          appBar: AppBar(
            title:
                isLoaded
                    ? Text(roomName)
                    : CustomShimmerEffect.textWidget(width: 180, fontSize: 20),
            titleSpacing: _mainScreenPadding.left,
            leading: appBarBackButton(context),
            centerTitle: false,
            actions: appBarActionButton(context, [
              IconButton(onPressed: () => {}, icon: Icon(Iconsax.info_circle)),
            ]),
          ),
          body: RefreshIndicator(
            onRefresh: onRefresh,
            notificationPredicate: notificationPredicateHandler,
            child: CustomGestureDetector(
              navBarIndex: _navbarSelectedIndex,
              totalTitle: _navBarTitles.length,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: paddingInsets,
                    sliver: SliverToBoxAdapter(child: _roomSummaryCard()),
                  ),
                  ValueListenableBuilder(
                    valueListenable: _navbarSelectedIndex,
                    builder: (context, value, _) {
                      return SliverPadding(
                        padding: paddingInsets.add(EdgeInsets.only(top: 8)),
                        sliver: SliverAppBar(
                          pinned: true,
                          toolbarHeight: _navBarHeight,
                          automaticallyImplyLeading: false,
                          backgroundColor: Colors.white,
                          surfaceTintColor: Colors.transparent,
                          flexibleSpace: FlexibleSpaceBar(
                            centerTitle: true,
                            title: NavBarCard(
                              headerTitle: _navBarTitles,
                              selectedIndex: _navbarSelectedIndex,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: _navbarSelectedIndex,
                    builder: (context, value, _) {
                      return SliverPadding(
                        padding: _mainScreenPadding,
                        sliver: _navBarHandler(value),
                      );
                    },
                  ),
                  SliverPadding(
                    padding: EdgeInsets.only(top: UiConstant.spaceAtBottom),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton:
              isRoomActive
                  ? SpeedDial(
                    icon: Iconsax.add,
                    activeIcon: Icons.close,
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    spacing: 3,
                    openCloseDial: isDialOpen,
                    childPadding: const EdgeInsets.all(5),
                    spaceBetweenChildren: 4,
                    useRotationAnimation: true,
                    animationCurve: Curves.elasticInOut,
                    children: [
                      SpeedDialChild(
                        child: const Icon(Iconsax.add),
                        backgroundColor: UiConstant.colors[0],
                        foregroundColor: Colors.white,
                        label: 'Add Expense',
                        visible: roomUserModel.active,
                        onTap: () {
                          context.push(
                            "${RouterConstants.roomRouteName}/${widget.id}${RouterConstants.roomAddExpenseRouteName}",
                          );
                        },
                      ),
                      SpeedDialChild(
                        child: const Icon(Icons.arrow_outward),
                        backgroundColor: UiConstant.colors[1],
                        foregroundColor: Colors.white,
                        visible: roomUserModel.active && showSettleExpense,
                        label: 'Add Settle Expense',
                        onTap: () {
                          context.push(
                            "${RouterConstants.roomRouteName}/${widget.id}${RouterConstants.roomSettleAddRouteName}",
                          );
                        },
                      ),
                      SpeedDialChild(
                        child: const Icon(Iconsax.profile_add),
                        backgroundColor: UiConstant.colors[2],
                        foregroundColor: Colors.white,
                        label: 'Add Member',
                        visible: roomUserModel.active,
                        onTap: () async {
                          CreateJoinRoomCubit createJoinRoomCubit =
                              context.read<CreateJoinRoomCubit>();
                          ScaffoldMessengerState scaffoldMessengerState =
                              ScaffoldMessenger.of(context);
                          final userDataFromScreen =
                              await context.push(
                                    currentRoute + RouterConstants.inviteMember,
                                    extra: {
                                      "transactionType": TransactionType.room,
                                    },
                                  )
                                  as List<UserModel>?;
                          if (userDataFromScreen != null &&
                              userDataFromScreen.isNotEmpty) {
                            createJoinRoomCubit.inviteMember(
                              widget.id,
                              userDataFromScreen,
                              _loggedInUser.authToken,
                              scaffoldMessengerState,
                            );
                          }
                        },
                      ),
                      SpeedDialChild(
                        child: const Icon(Iconsax.lock),
                        backgroundColor: UiConstant.colors[3],
                        foregroundColor: Colors.white,
                        visible: roomUserModel.active,
                        label: 'Close Room',
                        onTap: () {
                          if (!roomUserModel.hasData) {
                            return;
                          }
                          double unSettledAmount =
                              roomUserModel.contribution -
                              roomUserModel.spent +
                              roomUserModel.settle;
                          if (unSettledAmount.abs() < 0.2) {
                            _closeRoomPopupDialog();
                          } else {
                            showNormalSnackBar(context, "Settle Your Spending");
                          }
                        },
                      ),
                      SpeedDialChild(
                        child: const Icon(Iconsax.message_question),
                        backgroundColor: UiConstant.colors[4],
                        foregroundColor: Colors.white,
                        visible: isRoomActive && showCloseRoomRequest,
                        label: 'Close Room Request',
                        onTap: () {
                          context
                              .read<RoomCloseRequestCubit>()
                              .closeRoomRequest(
                                widget.id,
                                _loggedInUser.authToken,
                              );
                        },
                      ),
                    ],
                  )
                  : null,
        );
      },
    );
  }
}
