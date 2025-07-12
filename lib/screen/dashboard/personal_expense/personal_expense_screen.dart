import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/personal_expense/monthly_expense/personal_expense_bloc.dart';
import 'package:settlenow_v2/constant/calender_constant.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/screen/dashboard/personal_expense/sub_section/personal_expense_categories_section_screen.dart';
import 'package:settlenow_v2/screen/dashboard/personal_expense/sub_section/personal_expense_transaction_screen.dart';
import 'package:settlenow_v2/util/custom/custom_gesture_detector.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/graph/linear_graph_card.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/navbar_widget.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class PersonalExpenseScreen extends StatefulWidget {
  final String month;
  final String year;
  const PersonalExpenseScreen({
    super.key,
    required this.month,
    required this.year,
  });

  @override
  State<PersonalExpenseScreen> createState() => _PersonalExpenseScreenState();
}

class _PersonalExpenseScreenState extends State<PersonalExpenseScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  final ValueNotifier<int> _navbarSelectedIndex = ValueNotifier(0);
  final double _navBarHeight = 60;
  final DateTime _currentDate = DateTime.now();
  bool _isLivePersonalExpense = false;
  UserModel _loggedInUser = UserModel.empty();
  final List<String> headerTitle = ["Categories", "Transaction"];

  void _blocListenerHandler(
    BuildContext context,
    PersonalMonthlyExpenseState state,
  ) {
    if (state is PersonalMonthlyExpenseFailure) {
      showNormalSnackBar(context, state.error);
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

    if (_currentDate.year.toString() == widget.year &&
        CalenderConstant.getIndexOfMonth(widget.month) + 1 ==
            _currentDate.month) {
      _isLivePersonalExpense = true;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;

      final state = context.read<PersonalMonthlyExpenseBloc>().state;
      if (!(state is PersonalMonthlyExpenseFetchSuccess &&
          state.id == (widget.year + widget.month).toLowerCase())) {
        context.read<PersonalMonthlyExpenseBloc>().add(
          PersonalMonthlyExpenseFetch(
            authToken: _loggedInUser.authToken,
            year: widget.year,
            month: widget.month,
          ),
        );
      }
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
        title: Text("${capatilizeFirstLetter(widget.month)}, ${widget.year}"),
        titleSpacing: _mainScreenPadding.left,
        leading: appBarBackButton(context),
      ),
      body: CustomGestureDetector(
        navBarIndex: _navbarSelectedIndex,
        totalTitle: headerTitle.length,
        child: BlocConsumer<
          PersonalMonthlyExpenseBloc,
          PersonalMonthlyExpenseState
        >(
          listener: _blocListenerHandler,
          builder: (context, state) {
            if (state is PersonalMonthlyExpenseFetchSuccess &&
                state.data.isEmpty) {
              return noRecordFoundWidget("No Transaction Found");
            }
            return CustomScrollView(
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
                      title: Builder(
                        builder: (context) {
                          if (state is PersonalMonthlyExpenseFetchSuccess) {
                            return LinearGraphCard(
                              expenses:
                                  state.data.map((ele) => ele.amount).toList(),
                            );
                          } else {
                            return CustomShimmerEffect.placeHolderShimmerEffect(
                              Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 24,
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(24),
                                          bottomRight: Radius.circular(24),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
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
                            headerTitle: headerTitle,
                            selectedIndex: _navbarSelectedIndex,
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
                  child: SizedBox(
                    height: UiConstant.spaceAtBottom + _navBarHeight,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton:
          _isLivePersonalExpense
              ? CustomButton.customFloatingButton(Iconsax.add, () {
                context.push(
                  "${RouterConstants.personalExpenseRouteName}/${widget.year}/${widget.month}${RouterConstants.personalExpenseAddExpenseRouteName}",
                );
              })
              : null,
    );
  }
}
