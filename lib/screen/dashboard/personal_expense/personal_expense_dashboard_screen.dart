import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/constant/constant_core.dart';

import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/provider/provider_core.dart';
import 'package:settlenow/util/util_core.dart';

class PersonalExpenseDashboardScreen extends StatefulWidget {
  final ValueNotifier<bool> isSearchEnabled;
  const PersonalExpenseDashboardScreen({
    super.key,
    required this.isSearchEnabled,
  });

  @override
  State<PersonalExpenseDashboardScreen> createState() =>
      _PersonalExpenseDashboardScreenState();
}

class _PersonalExpenseDashboardScreenState
    extends State<PersonalExpenseDashboardScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  final TextEditingController _searchController = TextEditingController();
  List<double> cardSizeInfo = List.filled(2, 0);
  UserModel _loggedInUser = UserModel.empty();
  final ScrollController _gridViewScrollController = ScrollController();

  void _blocListenerHandler(
    BuildContext context,
    PersonalExpenseDashboardState state,
  ) {
    if (state is PersonalExpenseDashboardFailure) {
      showNormalSnackBar(context, state.error);
    } else if (state is PersonalExpenseDashboardFetchSuccess &&
        state.error != null) {
      showNormalSnackBar(context, state.error!);
    }
  }

  Widget monthWiseCardsWidget(List<PersonalExpenseInfoModel> transactionData) {
    return SliverPadding(
      padding: _mainScreenPadding,
      sliver: SliverGrid.builder(
        itemCount: transactionData.length,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: cardSizeInfo[0],
          mainAxisSpacing: UiConstant.spaceBetweenCard,
          crossAxisSpacing: UiConstant.spaceBetweenCard,
          childAspectRatio: cardSizeInfo[1],
        ),
        itemBuilder: (BuildContext context, int index) {
          return PersonalExpenseCard(data: transactionData[index]);
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainScreenPadding = context.watch<ScreenSizeProvider>().getPadding;
    cardSizeInfo = calculateCrossAspectRatio(
      context,
      MediaQuery.of(context).size.width,
      _mainScreenPadding,
      cardWidth: UiConstant.cardFixedHeight + 20,
      cardHeight: UiConstant.cardFixedHeight,
    );
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

      final state = context.read<PersonalExpenseDashboardBloc>().state;
      if (state is! PersonalExpenseDashboardFetchSuccess) {
        context.read<PersonalExpenseDashboardBloc>().add(
          PersonalExpenseDashboardFetch(isFreshFetch: true),
        );
      }

      addPaginationListener<
        PersonalExpenseDashboardBloc,
        PersonalExpenseDashboardState
      >(
        scrollController: _gridViewScrollController,
        context: context,
        hasMore:
            (state) =>
                state is PersonalExpenseDashboardFetchSuccess &&
                state.hasMoreData,
        isLoadingMore:
            (state) =>
                state is PersonalExpenseDashboardFetchSuccess &&
                state.isLoadingMore,
        onFetch:
            () => context.read<PersonalExpenseDashboardBloc>().add(
              PersonalExpenseDashboardFetch(isFreshFetch: false),
            ),
      );
    }
  }

  @override
  void dispose() {
    _gridViewScrollController.dispose();
    super.dispose();
  }

  Widget _builderFooter(
    BuildContext context,
    PersonalExpenseDashboardState state,
  ) {
    if (state is PersonalExpenseDashboardFetchSuccess) {
      return buildFooter(context, state.isLoadingMore, state.hasMoreData);
    }

    return const SizedBox.shrink();
  }

  Future<void> onRefresh() async {
    if (!_loggedInUser.hasData) {
      showNormalSnackBar(
        context,
        SnackbarMessageConstant.sessionExpiredMessage,
      );
      return;
    }
    context.read<PersonalExpenseDashboardBloc>().add(
      PersonalExpenseDashboardFetch(isFreshFetch: true),
    );
  }

  List<PersonalExpenseInfoModel> filterDataByPreference(
    List<PersonalExpenseInfoModel> oldData,
    EmptyPreferenceSection pref,
  ) {
    if (pref.showEmpty) {
      return oldData;
    }

    return oldData.where((value) {
      int monthIndex = CalenderConstant.getIndexOfMonth(value.monthName) + 1;

      return (value.amount > 0 ||
          (DateTime.now().year.toString() == value.year &&
              monthIndex == DateTime.now().month));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferenceProvider>(
      builder: (context, prefData, _) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: onRefresh,
            notificationPredicate: (ScrollNotification notification) {
              return notification.depth == 0;
            },
            child: CustomScrollView(
              controller: _gridViewScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                ValueListenableBuilder(
                  valueListenable: widget.isSearchEnabled,
                  builder: (BuildContext context, bool value, Widget? _) {
                    if (!value) {
                      return SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                    return SliverPadding(
                      padding: _mainScreenPadding,
                      sliver: SliverAppBar(
                        automaticallyImplyLeading: false,
                        pinned: value,
                        title: CustomFormField.searchBar(
                          "Search",
                          widget.isSearchEnabled,
                          _searchController,
                        ),
                      ),
                    );
                  },
                ),
                BlocConsumer<
                  PersonalExpenseDashboardBloc,
                  PersonalExpenseDashboardState
                >(
                  listener: _blocListenerHandler,
                  builder: (context, state) {
                    bool hasNoRecordFound = false;
                    List<PersonalExpenseInfoModel> transactionData = [];

                    if (state is PersonalExpenseDashboardFetchSuccess) {
                      hasNoRecordFound = state.dataList.isEmpty;
                      transactionData = filterDataByPreference(
                        state.dataList,
                        prefData.personalExpensePref,
                      );
                    } else if (state is PersonalExpenseDashboardLoading) {
                      transactionData = List.generate(
                        11,
                        (i) => PersonalExpenseInfoModel.empty(),
                      );
                    }

                    if (transactionData.isEmpty) {
                      return SliverFillRemaining(
                        child:
                            hasNoRecordFound
                                ? freshMessageWidget(
                                  FreshScreenMessageConstant
                                      .noPersonalMonthlyDashboard,
                                )
                                : noRecordFoundWidget(
                                  ApiConstant.noPersonalExpenseFound,
                                  context,
                                ),
                      );
                    }

                    return ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _searchController,
                      builder: (context, _, _) {
                        List<PersonalExpenseInfoModel> filterData =
                            transactionData;
                        if (state is PersonalExpenseDashboardFetchSuccess) {
                          filterData = FilterSort.filteredSearchText(
                            _searchController.text,
                            transactionData,
                            (roomData) {
                              return "${roomData.monthName} ${roomData.year}";
                            },
                          );
                        }

                        if (filterData.isEmpty) {
                          return SliverFillRemaining(
                            child: noRecordFoundWidget(
                              ApiConstant.noMatchingRecords,
                              context,
                            ),
                          );
                        }
                        return SliverMainAxisGroup(
                          slivers: [
                            monthWiseCardsWidget(filterData),
                            genericFooterForDashboard(
                              widget.isSearchEnabled,
                              _builderFooter,
                              context,
                              state,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          floatingActionButton: BlocBuilder<
            PersonalExpenseDashboardBloc,
            PersonalExpenseDashboardState
          >(
            builder: (context, state) {
              if (state is PersonalExpenseDashboardFetchSuccess) {
                DateTime now = DateTime.now();
                String year = now.year.toString();
                int month = now.month - 1;

                PersonalExpenseInfoModel currentMonthPersonalExpense = state
                    .dataList
                    .firstWhere(
                      (ele) =>
                          year == ele.year &&
                          CalenderConstant.getIndexOfMonth(ele.monthName) ==
                              month,
                      orElse: () => PersonalExpenseInfoModel.empty(),
                    );

                if (!currentMonthPersonalExpense.hasData) {
                  return CustomButton.customFloatingButton(
                    Iconsax.add_copy,
                    () {
                      context.read<PersonalExpenseDashboardBloc>().add(
                        PersonalExpenseDashboardOnAdd(),
                      );
                    },
                  );
                } else {
                  return SizedBox.shrink();
                }
              } else {
                return SizedBox.shrink();
              }
            },
          ),
        );
      },
    );
  }
}
