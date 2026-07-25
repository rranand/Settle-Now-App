import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/constant/constant_core.dart';

import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/internationalization/currency.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/provider/provider_core.dart';
import 'package:settlenow/router/router_constant.dart';
import 'package:settlenow/screen/screen_core.dart';
import 'package:settlenow/util/util_core.dart';

class RoomExpenseScreen extends StatefulWidget {
  final String id;
  const RoomExpenseScreen({super.key, required this.id});

  @override
  State<RoomExpenseScreen> createState() => _RoomExpenseScreenState();
}

class _RoomExpenseScreenState extends State<RoomExpenseScreen> {
  final ValueNotifier<bool> isSearchEnabled = ValueNotifier(false);
  final TextEditingController _searchController = TextEditingController();
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
        return RoomTransactionScreen(
          roomID: widget.id,
          searchController: _searchController,
        );
    }
  }

  void _resetCubit() {
    final RoomSettleState roomSettleState =
        context.read<RoomSettleCubit>().state;

    if (roomSettleState is RoomSettleSuccess &&
        roomSettleState.id != widget.id) {
      context.read<RoomSettleCubit>().reset();
    }

    final RoomState roomState = context.read<RoomBloc>().state;
    if (roomState is RoomFetchSuccess && roomState.id != widget.id) {
      context.read<RoomBloc>().add(RoomBlocReset());
    }

    final RoomUserState roomUserState = context.read<RoomUserCubit>().state;
    if (roomUserState is RoomUserSuccess && roomUserState.id != widget.id) {
      context.read<RoomUserCubit>().reset();
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

  Widget _roomSummaryCard() {
    return BlocBuilder<RoomUserCubit, RoomUserState>(
      builder: (context, state) {
        if (state is RoomUserSuccess) {
          RoomUserModel data = RoomUserModel.empty();
          RoomUserModel ogData = RoomUserModel.empty();

          double totalSpent = 0;
          double ogTotalSpent = 0;

          for (int i = 0; i < state.data.length; i++) {
            if (_loggedInUser.id == state.data[i].user.id) {
              data = state.data[i];
            }
            totalSpent += state.data[i].contribution;
          }

          ogTotalSpent = totalSpent;
          ogData = data;

          double balance = getPrecisedAmount(
            data.contribution - data.spent + data.settle,
          );

          return BlocBuilder<FilterCubit, FilterState>(
            builder: (context, filterState) {
              bool haveFilter = filterState.isFilterApplied;
              if (haveFilter) {
                List<RoomUserModel> filteredExpenseInfo =
                    calculateUserExpenseInfo(
                      state.data,
                      filterState.data.cast<TransactionModel>(),
                      [],
                    );
                totalSpent = 0;
                for (int i = 0; i < filteredExpenseInfo.length; i++) {
                  if (_loggedInUser.id == filteredExpenseInfo[i].user.id) {
                    data = filteredExpenseInfo[i];
                  }
                  totalSpent += filteredExpenseInfo[i].contribution;
                }
              } else {
                totalSpent = ogTotalSpent;
                data = ogData;
              }

              return Stack(
                children: [
                  Card(
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
                  ),
                  haveFilter
                      ? Positioned(top: 12, right: 12, child: dot())
                      : SizedBox.shrink(),
                ],
              );
            },
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
            context,
          );
        }
      },
    );
  }

  Future<void> onRefresh() async {
    if (!_loggedInUser.hasData) {
      showNormalSnackBar(
        context,
        SnackbarMessageConstant.sessionExpiredMessage,
      );
      return;
    }
    final roomInfoCubit = context.read<RoomInfoCubit>();

    await roomInfoCubit.fetchData(widget.id, forceRefresh: true);
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

  void filterModelBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) {
        final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: const EdgeInsets.all(
            16.0,
          ).add(EdgeInsets.only(bottom: keyboardHeight)),
          child: FilterSheet(
            id: widget.id,
            transactionType: TransactionType.room,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _resetCubit();
    currentRoute =
        GoRouter.of(context).routeInformationProvider.value.uri.toString();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;

      final filterState = context.read<FilterCubit>().state;
      if (filterState.id != widget.id) {
        context.read<FilterCubit>().updateState(
          FilterState(id: widget.id),
          _loggedInUser.id,
          TransactionType.room,
        );
      }

      final state = context.read<RoomBloc>().state;
      if (!(state is RoomFetchSuccess && state.id == widget.id)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<RoomInfoCubit>().fetchData(widget.id);
        });
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

  void callRoomUserBloc() {
    final RoomInfoState roomInfoState = context.read<RoomInfoCubit>().state;
    final RoomState roomState = context.read<RoomBloc>().state;
    final RoomSettleState roomSettleState =
        context.read<RoomSettleCubit>().state;

    if (roomState is RoomFetchSuccess &&
        roomState.id == widget.id &&
        roomInfoState is RoomInfoSuccess &&
        roomInfoState.data.id == widget.id &&
        roomSettleState is RoomSettleSuccess &&
        roomSettleState.id == widget.id) {
      context.read<RoomUserCubit>().fetchData(
        roomInfoState.data.id,
        roomInfoState.data.users,
        roomState.data,
        roomSettleState.data,
      );
    }
  }

  List<Widget>? appBarActionButtonHandler(
    bool isLoaded,
    bool isRoomActive,
    bool hasTransactionData,
  ) {
    List<Widget> appBarAction = [];
    final roomBlocState = context.watch<RoomBloc>().state;

    if (roomBlocState is RoomFetchSuccess) {
      appBarAction = [
        ValueListenableBuilder(
          valueListenable: _navbarSelectedIndex,
          builder: (context, _, _) {
            return Visibility(
              visible: _navbarSelectedIndex.value == 0 && hasTransactionData,
              child: InkWell(
                child: Icon(Icons.search),
                onTap: () {
                  isSearchEnabled.value = !isSearchEnabled.value;
                  _searchController.text = "";
                },
              ),
            );
          },
        ),
        ValueListenableBuilder(
          valueListenable: _navbarSelectedIndex,
          builder: (context, _, _) {
            return Visibility(
              visible: _navbarSelectedIndex.value <= 1 && hasTransactionData,
              child: IconButton(
                icon: BlocBuilder<FilterCubit, FilterState>(
                  builder: (context, state) {
                    bool haveFilter = state.isFilterApplied;
                    return Icon(
                      haveFilter
                          ? Iconsax.filter_tick_copy
                          : Iconsax.filter_copy,
                      color: haveFilter ? Colors.green : null,
                    );
                  },
                ),
                onPressed: () => filterModelBottomSheet(context),
              ),
            );
          },
        ),
      ];
    }

    if (isLoaded) {
      appBarAction.add(
        InkWell(
          child: Icon(Iconsax.activity_copy),
          onTap: () {
            context.push(
              "${RouterConstants.roomRouteName}/${widget.id}${RouterConstants.roomActivityRouteName}",
            );
          },
        ),
      );
      if (isRoomActive) {
        appBarAction.add(
          IconButton(
            icon: Icon(Iconsax.setting_copy),
            onPressed: () {
              context.push(
                "${RouterConstants.roomRouteName}/${widget.id}${RouterConstants.settingPage}",
              );
            },
          ),
        );
      }
    }

    return appBarActionButton(context, appBarAction);
  }

  @override
  void dispose() {
    isSearchEnabled.dispose();
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

          if (state.error.contains("Room Not Found")) {
            while (context.canPop()) {
              context.pop();
            }
          }
        } else if (state is RoomInfoInitial) {
          if (context.canPop()) {
            context.pop();
          }
        } else if (state is RoomInfoSuccess && !state.isInternalUpdate) {
          context.read<RoomSettleCubit>().fetchData(
            widget.id,
            state.data.users,
          );
          context.read<RoomBloc>().add(
            RoomFetch(id: widget.id, users: state.data.users),
          );
          context.read<RoomActivityCubit>().fetchData(widget.id);
        }
      },
      builder: (context, state) {
        bool isRoomActive = false;
        bool isLoaded = false;
        String roomName = "";
        RoomUserModel roomUserModel = RoomUserModel.empty();
        bool showSettleExpense = false;
        bool showCloseRoomRequest = false;
        bool hasTransactionData = false;

        if (state is RoomInfoSuccess) {
          isRoomActive = state.data.active;
          roomName = state.data.roomName;
          isLoaded = true;
          for (int i = 0; i < state.data.users.length; i++) {
            hasTransactionData =
                hasTransactionData || (state.data.users[i].contribution > 0);
            if (_loggedInUser.id == state.data.users[i].user.id) {
              roomUserModel = state.data.users[i];
            } else if (state.data.users[i].active) {
              showCloseRoomRequest = true;
            }
          }

          double unSettled = getPrecisedAmount(
            roomUserModel.contribution -
                roomUserModel.spent +
                roomUserModel.settle,
          );

          if (unSettled != 0) {
            showSettleExpense = true;
          }
        }

        return Scaffold(
          appBar: AppBar(
            title:
                isLoaded
                    ? Text(roomName)
                    : CustomShimmerEffect.textWidget(
                      context,
                      width: 180,
                      fontSize: 20,
                    ),
            titleSpacing: _mainScreenPadding.left,
            leading: appBarBackButton(context),
            centerTitle: false,
            actions: appBarActionButtonHandler(
              isLoaded,
              roomUserModel.active,
              hasTransactionData,
            ),
          ),
          body: RefreshIndicator(
            onRefresh: onRefresh,
            notificationPredicate: notificationPredicateHandler,
            child: CustomGestureDetector(
              navBarIndex: _navbarSelectedIndex,
              totalTitle: _navBarTitles.length,
              child: CustomScrollView(
                slivers: [
                  MultiValueListenableBuilder(
                    listenables: [isSearchEnabled, _navbarSelectedIndex],
                    builder: (BuildContext context) {
                      if (isSearchEnabled.value &&
                          _navbarSelectedIndex.value == 0) {
                        return SliverPadding(
                          padding: _mainScreenPadding,
                          sliver: SliverAppBar(
                            automaticallyImplyLeading: false,
                            pinned: isSearchEnabled.value,
                            title: CustomFormField.searchBar(
                              "Search",
                              isSearchEnabled,
                              _searchController,
                            ),
                          ),
                        );
                      } else {
                        return SliverPadding(
                          padding: paddingInsets,
                          sliver: SliverToBoxAdapter(child: _roomSummaryCard()),
                        );
                      }
                    },
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
                  MultiBlocListener(
                    listeners: [
                      BlocListener<RoomBloc, RoomState>(
                        listener: (context, state) {
                          if (state is RoomFetchSuccess) {
                            callRoomUserBloc();
                          }
                        },
                      ),
                      BlocListener<RoomSettleCubit, RoomSettleState>(
                        listener: (context, state) {
                          if (state is RoomSettleSuccess) {
                            callRoomUserBloc();
                          }
                        },
                      ),
                    ],
                    child: ValueListenableBuilder(
                      valueListenable: _navbarSelectedIndex,
                      builder: (context, value, _) {
                        return SliverPadding(
                          padding: _mainScreenPadding,
                          sliver: _navBarHandler(value),
                        );
                      },
                    ),
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
                    icon: Iconsax.add_copy,
                    activeIcon: Icons.close,
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    spacing: 3,
                    openCloseDial: isDialOpen,
                    childPadding: const EdgeInsets.all(5),
                    spaceBetweenChildren: 4,
                    useRotationAnimation: true,
                    animationCurve: Curves.elasticInOut,
                    children: [
                      SpeedDialChild(
                        child: const Icon(Iconsax.add_copy),
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
                        child: const Icon(Icons.library_add_outlined),
                        backgroundColor: UiConstant.colors[1],
                        foregroundColor: Colors.white,
                        label: 'Add Bulk Expense',
                        visible: roomUserModel.active,
                        onTap: () {
                          context.push(
                            "${RouterConstants.roomRouteName}/${widget.id}${RouterConstants.roomAddBulkExpenseRouteName}",
                          );
                        },
                      ),
                      SpeedDialChild(
                        child: const Icon(Icons.arrow_outward),
                        backgroundColor: UiConstant.colors[2],
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
                        child: const Icon(Iconsax.profile_add_copy),
                        backgroundColor: UiConstant.colors[3],
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
                              scaffoldMessengerState,
                            );
                          }
                        },
                      ),
                      SpeedDialChild(
                        child: const Icon(Iconsax.lock_copy),
                        backgroundColor: UiConstant.colors[4],
                        foregroundColor: Colors.white,
                        visible: roomUserModel.active,
                        label: 'Close Room',
                        onTap: () {
                          if (!roomUserModel.hasData) {
                            return;
                          }

                          double unSettled = getPrecisedAmount(
                            roomUserModel.contribution -
                                roomUserModel.spent +
                                roomUserModel.settle,
                          );
                          if (unSettled == 0) {
                            _closeRoomPopupDialog();
                          } else {
                            showNormalSnackBar(context, "Settle Your Spending");
                          }
                        },
                      ),
                      SpeedDialChild(
                        child: const Icon(Iconsax.message_question_copy),
                        backgroundColor: UiConstant.colors[5],
                        foregroundColor: Colors.white,
                        visible: isRoomActive && showCloseRoomRequest,
                        label: 'Close Room Request',
                        onTap: () {
                          context
                              .read<RoomCloseRequestCubit>()
                              .closeRoomRequest(widget.id);
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
