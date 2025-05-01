import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/constant/gradient_color_constant.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/screen/dashboard/room/sub_section/room_analysis_screen.dart';
import 'package:settlenow_v2/screen/dashboard/room/sub_section/room_settle_screen.dart';
import 'package:settlenow_v2/screen/dashboard/room/sub_section/room_transaction_screen.dart';
import 'package:settlenow_v2/screen/dashboard/room/sub_section/room_user_screen.dart';
import 'package:settlenow_v2/util/widgets/navbar_widget.dart';
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
      case 0:
        return RoomTransactionScreen();
      case 1:
        return RoomUserScreen(users: UiConstant.users);
      case 2:
        return RoomAnalysisScreen();
      case 3:
        return RoomSettleScreen();
      default:
        return RoomUserScreen(users: UiConstant.users);
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
    final isWide = MediaQuery.of(context).size.width >= UiConstant.maxWidth;
    EdgeInsets paddingInsets = _mainScreenPadding;
    if (!isWide) {
      paddingInsets = EdgeInsets.symmetric(horizontal: 8);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id),
        titleSpacing: _mainScreenPadding.left,
        leading: appBarBackButton(context),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: paddingInsets,
            sliver: SliverToBoxAdapter(
              child: Card(
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
                          _summaryBox("Total Spent", "₹ 15,000"),
                          _summaryBox("You Gave", "₹ 6,000"),
                          _summaryBox("You Owe", "₹ 3,500"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
    );
  }
}
