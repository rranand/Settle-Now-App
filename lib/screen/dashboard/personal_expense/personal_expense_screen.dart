import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/personal_expense/monthly_expense/personal_expense_bloc.dart';
import 'package:settlenow_v2/constant/calender_constant.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/cubit/filter/filter_cubit.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/screen/dashboard/personal_expense/sub_section/personal_expense_categories_section_screen.dart';
import 'package:settlenow_v2/screen/dashboard/personal_expense/sub_section/personal_expense_transaction_screen.dart';
import 'package:settlenow_v2/util/custom/custom_gesture_detector.dart';
import 'package:settlenow_v2/util/enum/transaction_type.dart';
import 'package:settlenow_v2/util/filter/filter_sheet.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/graph/linear_graph_card.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
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
  final ValueNotifier<bool> isSearchEnabled = ValueNotifier(false);
  final TextEditingController _searchController = TextEditingController();
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  final ValueNotifier<int> _navbarSelectedIndex = ValueNotifier(0);
  final double _navBarHeight = 60;
  final DateTime _currentDate = DateTime.now();
  bool _isLivePersonalExpense = false;
  UserModel _loggedInUser = UserModel.empty();
  final List<String> headerTitle = ["Categories", "Transaction"];
  List<RoomLinkedModel> roomData = [];
  final double filterHeightSize = 400;

  void _blocListenerHandler(
    BuildContext context,
    PersonalMonthlyExpenseState state,
  ) {
    if (state is PersonalMonthlyExpenseFailure) {
      showNormalSnackBar(context, state.error);
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
      backgroundColor: Colors.white,
      builder: (context) {
        final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: const EdgeInsets.all(
            16.0,
          ).add(EdgeInsets.only(bottom: keyboardHeight)),
          child: FilterSheet(
            id: '${widget.year}${widget.month}'.toLowerCase(),
            transactionType: TransactionType.personal,
          ),
        );
      },
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

    if (_currentDate.year.toString() == widget.year &&
        CalenderConstant.getIndexOfMonth(widget.month) + 1 ==
            _currentDate.month) {
      _isLivePersonalExpense = true;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;

      final filterState = context.read<FilterCubit>().state;
      String id = widget.year + widget.month.toLowerCase();
      if (filterState.id != id) {
        context.read<FilterCubit>().updateState(
          FilterState(id: id),
          _loggedInUser.id,
          TransactionType.personal,
        );
      }
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

  Future<void> onRefresh() async {
    if (!_loggedInUser.hasData) {
      showNormalSnackBar(context, "Please re-login...Session expired!");
      return;
    }
    context.read<PersonalMonthlyExpenseBloc>().add(
      PersonalMonthlyExpenseFetch(
        authToken: _loggedInUser.authToken,
        year: widget.year,
        month: widget.month,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= UiConstant.maxWidth;
    EdgeInsets paddingInsets = _mainScreenPadding;
    if (!isWide) {
      paddingInsets = EdgeInsets.zero;
    }

    return BlocConsumer<
      PersonalMonthlyExpenseBloc,
      PersonalMonthlyExpenseState
    >(
      listener: _blocListenerHandler,
      builder: (context, state) {
        List<PersonalExpenseTransactionModel> transactionArr = [];
        bool isLoaded = false;

        if (state is PersonalMonthlyExpenseFetchSuccess) {
          isLoaded = true;
          if (state.data.isNotEmpty) {
            transactionArr = state.data;
            context.read<FilterCubit>().updateState(
              FilterState(id: state.id, data: state.data),
              _loggedInUser.id,
              TransactionType.personal,
            );
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              "${capatilizeFirstLetter(widget.month)}, ${widget.year}",
            ),
            titleSpacing: _mainScreenPadding.left,
            leading: appBarBackButton(context),
            centerTitle: false,
            actions:
                (transactionArr.isEmpty || !isLoaded)
                    ? null
                    : appBarActionButton(context, [
                      InkWell(
                        borderRadius: BorderRadius.circular(
                          UiConstant.cardBorderRadius,
                        ),
                        child: Icon(Icons.search),
                        onTap: () {
                          isSearchEnabled.value = !isSearchEnabled.value;
                          _searchController.text = "";
                          if (isSearchEnabled.value &&
                              _navbarSelectedIndex.value == 0) {
                            _navbarSelectedIndex.value = 1;
                          }
                        },
                      ),
                      IconButton(
                        icon: BlocBuilder<FilterCubit, FilterState>(
                          builder: (context, state) {
                            bool haveFilter = state.isFilterApplied;
                            return Icon(
                              haveFilter ? Iconsax.filter_tick : Iconsax.filter,
                              color: haveFilter ? Colors.green : null,
                            );
                          },
                        ),
                        onPressed: () => filterModelBottomSheet(context),
                      ),
                    ]),
          ),
          body: RefreshIndicator(
            onRefresh: onRefresh,
            notificationPredicate: (ScrollNotification notification) {
              final state = context.read<PersonalMonthlyExpenseBloc>().state;
              if (state is PersonalMonthlyExpenseFetchSuccess &&
                  state.data.isNotEmpty) {
                return notification.depth == 0;
              } else {
                return notification.depth == 1;
              }
            },
            child: CustomGestureDetector(
              navBarIndex: _navbarSelectedIndex,
              totalTitle: headerTitle.length,
              child: CustomScrollView(
                slivers:
                    transactionArr.isEmpty && isLoaded
                        ? [
                          SliverToBoxAdapter(
                            child: noRecordFoundWidget(
                              "No Transaction Found",
                              context,
                            ),
                          ),
                        ]
                        : [
                          ValueListenableBuilder(
                            valueListenable: isSearchEnabled,
                            builder: (context, _, _) {
                              if (!isSearchEnabled.value) {
                                return SliverToBoxAdapter(
                                  child: SizedBox.shrink(),
                                );
                              }
                              return SliverPadding(
                                padding: _mainScreenPadding,
                                sliver: SliverAppBar(
                                  automaticallyImplyLeading: false,
                                  pinned: isSearchEnabled.value,
                                  backgroundColor: Colors.white,
                                  surfaceTintColor: Colors.white,
                                  title: CustomFormField.searchBar(
                                    "Search",
                                    isSearchEnabled,
                                    _searchController,
                                  ),
                                ),
                              );
                            },
                          ),
                          ValueListenableBuilder(
                            valueListenable: isSearchEnabled,
                            builder: (BuildContext context, _, _) {
                              return BlocBuilder<FilterCubit, FilterState>(
                                builder: (context, filterState) {
                                  if (filterState.isFilterApplied ||
                                      isSearchEnabled.value) {
                                    return SliverToBoxAdapter(
                                      child: SizedBox.shrink(),
                                    );
                                  }
                                  return SliverPadding(
                                    padding: paddingInsets,
                                    sliver: SliverAppBar(
                                      toolbarHeight: 330,
                                      automaticallyImplyLeading: false,
                                      backgroundColor: Colors.transparent,
                                      surfaceTintColor: Colors.transparent,
                                      flexibleSpace: FlexibleSpaceBar(
                                        centerTitle: false,
                                        title:
                                            isLoaded
                                                ? LinearGraphCard(
                                                  expenses:
                                                      transactionArr
                                                          .map(
                                                            (ele) => ele.amount,
                                                          )
                                                          .toList(),
                                                )
                                                : CustomShimmerEffect.placeHolderShimmerEffect(
                                                  Column(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                vertical: 24,
                                                                horizontal: 16,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius.only(
                                                                  bottomLeft:
                                                                      Radius.circular(
                                                                        24,
                                                                      ),
                                                                  bottomRight:
                                                                      Radius.circular(
                                                                        24,
                                                                      ),
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
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
                              builder: (context, _, _) {
                                if (_navbarSelectedIndex.value == 0) {
                                  return PersonalExpenseCategoriesSectionScreen();
                                } else {
                                  return PersonalExpenseTransactionScreen(
                                    searchController: _searchController,
                                  );
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
              ),
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
      },
    );
  }
}
