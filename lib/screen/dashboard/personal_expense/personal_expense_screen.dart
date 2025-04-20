import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/screen/dashboard/personal_expense/sub_section/personal_expense_categories_section_screen.dart';
import 'package:settlenow_v2/screen/dashboard/personal_expense/sub_section/personal_expense_transaction_screen.dart';
import 'package:settlenow_v2/util/graph/linear_graph_card.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/navbar_widget.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class PersonalExpenseScreen extends StatefulWidget {
  final String id;
  const PersonalExpenseScreen({super.key, required this.id});

  @override
  State<PersonalExpenseScreen> createState() => _PersonalExpenseScreenState();
}

class _PersonalExpenseScreenState extends State<PersonalExpenseScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  final ValueNotifier<int> _navbarSelectedIndex = ValueNotifier(0);
  final double _navBarHeight = 60;
  final List<double> amountData = [
    120.0,
    95.5,
    110.0,
    130.2,
    105.0,
    99.9,
    142.3,
    125.0,
    98.0,
    114.0,
    150.0,
    97.3,
    121.0,
    135.6,
    100.0,
    92.4,
    160.0,
    145.2,
    118.0,
    106.6,
    102.0,
    134.3,
    141.0,
    123.9,
    108.0,
    117.0,
    139.0,
    127.4,
    112.0,
    149.0,
  ];

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
      paddingInsets = EdgeInsets.zero;
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
            sliver: SliverAppBar(
              toolbarHeight: 330,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                title: LinearGraphCard(
                  expenses: amountData,
                  monthName: "April",
                ),
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: _navbarSelectedIndex,
            builder: (context, value, _) {
              return SliverPadding(
                padding: paddingInsets,
                sliver: SliverAppBar(
                  pinned: true,
                  toolbarHeight: _navBarHeight,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: NavBarCard(
                      headerTitle: ["Categories", "Transaction"],
                      selectedIndex: _navbarSelectedIndex,
                      width:
                          MediaQuery.of(context).size.width -
                          2 * paddingInsets.left,
                    ),
                  ),
                ),
              );
            },
          ),
          SliverPadding(
            padding: paddingInsets,
            sliver: ValueListenableBuilder(
              valueListenable: _navbarSelectedIndex,
              builder: (context, value, _) {
                if (value == 0) {
                  return PersonalExpenseCategoriesSectionScreen();
                } else {
                  return PersonalExpenseTransactionScreen();
                }
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: UiConstant.spaceAtBottom + _navBarHeight),
          ),
        ],
      ),
      floatingActionButton: CustomButton.customFloatingButton(
        Iconsax.add,
        () {},
      ),
    );
  }
}
