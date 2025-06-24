import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/room/each_room/room_bloc.dart';
import 'package:settlenow_v2/constant/gradient_color_constant.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
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
          double totalSpent = 0;
          for (int i = 0; i < state.data.length; i++) {
            if (_loggedInUser.id == state.data[i].user.id) {
              data = state.data[i];
            }
            totalSpent += state.data[i].contribution;
          }
          double balance = data.contribution - data.spent + data.settle;

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
                        "${balance < 0 ? "-" : "+"}${formatCurrency(balance, context)}",
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

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;
    }

    final state = context.read<RoomBloc>().state;

    if (!(state is RoomFetchSuccess && state.id == widget.id)) {
      context.read<RoomInfoCubit>().fetchData(
        widget.id,
        _loggedInUser.authToken,
      );
      context.read<RoomBloc>().add(
        RoomFetch(id: widget.id, authToken: _loggedInUser.authToken),
      );
      context.read<RoomUserCubit>().fetchData(
        widget.id,
        _loggedInUser.authToken,
      );
      context.read<RoomSettleCubit>().fetchData(widget.id);
    }
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
        return Scaffold(
          appBar: AppBar(
            title:
                (state is RoomInfoSuccess)
                    ? Text(state.data.roomName)
                    : CustomShimmerEffect.textWidget(width: 180, fontSize: 20),
            titleSpacing: _mainScreenPadding.left,
            leading: appBarBackButton(context),
          ),
          body: CustomScrollView(
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
          floatingActionButton: SpeedDial(
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
                visible: true,
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
                label: 'Add Settle Expense',
                onTap: () {
                  context.push(
                    "${RouterConstants.roomRouteName}/${widget.id}${RouterConstants.roomSettleAddRouteName}",
                  );
                },
              ),
              SpeedDialChild(
                child: const Icon(Iconsax.lock),
                backgroundColor: UiConstant.colors[2],
                foregroundColor: Colors.white,
                label: 'Close Room',
                onTap: () {},
              ),
              SpeedDialChild(
                child: const Icon(Iconsax.message_question),
                backgroundColor: UiConstant.colors[3],
                foregroundColor: Colors.white,
                label: 'Close Room Request',
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
