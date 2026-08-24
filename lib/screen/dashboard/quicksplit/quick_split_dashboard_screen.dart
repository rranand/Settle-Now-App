import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/constant/constant_core.dart';

import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/provider/provider_core.dart';
import 'package:settlenow/router/router_constant.dart';
import 'package:settlenow/util/util_core.dart';

class QuickSplitDashboardScreen extends StatefulWidget {
  final ValueNotifier<bool> isSearchEnabled;
  const QuickSplitDashboardScreen({super.key, required this.isSearchEnabled});

  @override
  State<QuickSplitDashboardScreen> createState() =>
      _QuickSplitDashboardScreenState();
}

class _QuickSplitDashboardScreenState extends State<QuickSplitDashboardScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  final TextEditingController _searchController = TextEditingController();
  UserModel _loggedInUser = UserModel.empty();
  final ScrollController _gridViewScrollController = ScrollController();

  void _blocListenerHandler(BuildContext context, QuicksplitState state) {
    if (state is QuicksplitFailure) {
      showNormalSnackBar(context, state.error);
    } else if (state is QuicksplitFetchSuccess && state.error != null) {
      showNormalSnackBar(context, state.error!);
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
  void dispose() {
    _searchController.dispose();
    _gridViewScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;

      final state = context.read<QuicksplitBloc>().state;

      if (state is! QuicksplitFetchSuccess) {
        context.read<QuicksplitBloc>().add(QuicksplitFetch(isFreshFetch: true));
      }

      addPaginationListener<QuicksplitBloc, QuicksplitState>(
        scrollController: _gridViewScrollController,
        context: context,
        hasMore:
            (state) => state is QuicksplitFetchSuccess && state.hasMoreData,
        isLoadingMore:
            (state) => state is QuicksplitFetchSuccess && state.isLoadingMore,
        onFetch:
            () => context.read<QuicksplitBloc>().add(
              QuicksplitFetch(isFreshFetch: false),
            ),
      );
    }

    widget.isSearchEnabled.addListener(() {
      _searchController.text = "";
    });
  }

  Future<void> onRefresh() async {
    if (!_loggedInUser.hasData) {
      showNormalSnackBar(
        context,
        SnackbarMessageConstant.sessionExpiredMessage,
      );
      return;
    }
    context.read<QuicksplitBloc>().add(QuicksplitFetch(isFreshFetch: true));
  }

  Widget _builderFooter(BuildContext context, QuicksplitState state) {
    if (state is QuicksplitFetchSuccess) {
      return buildFooter(context, state.isLoadingMore, state.hasMoreData);
    }

    return const SizedBox.shrink();
  }

  List<QuicksplitTransactionModel> filterDataByPreference(
    List<QuicksplitTransactionModel> oldData,
    PreferenceSection pref,
  ) {
    if (pref.isSettled) {
      return oldData;
    }

    return oldData.where((value) {
      bool isSettledByYou =
          value.users
              .firstWhere(
                (ele) => ele.id == _loggedInUser.id,
                orElse: () => QuicksplitUserModel.empty(),
              )
              .isSettled;

      if (pref.isSettled != isSettledByYou) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width > UiConstant.maxWidth;

    return Consumer<PreferenceProvider>(
      builder: (context, prefData, _) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: onRefresh,
            notificationPredicate: (ScrollNotification notification) {
              return notification.depth == 0;
            },
            child: BlocConsumer<QuicksplitBloc, QuicksplitState>(
              listener: _blocListenerHandler,
              builder: (context, state) {
                bool hasNoRecordFound = false;
                List<QuicksplitTransactionModel> splitData = [];
                if (state is QuicksplitFetchSuccess) {
                  hasNoRecordFound = state.dataList.isEmpty;
                  splitData = filterDataByPreference(
                    state.dataList,
                    prefData.quicksplitPref,
                  );
                } else if (state is QuicksplitLoading) {
                  splitData = List.generate(
                    11,
                    (i) => QuicksplitTransactionModel.empty(),
                  );
                }

                return CustomScrollView(
                  controller: _gridViewScrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers:
                      splitData.isEmpty
                          ? [
                            SliverFillRemaining(
                              child:
                                  hasNoRecordFound
                                      ? freshMessageWidget(
                                        FreshScreenMessageConstant
                                            .noQuicksplitDashboard,
                                      )
                                      : noRecordFoundWidget(
                                        ApiConstant.noTransactionFound,
                                        context,
                                      ),
                            ),
                          ]
                          : [
                            ValueListenableBuilder(
                              valueListenable: widget.isSearchEnabled,
                              builder: (
                                BuildContext context,
                                bool value,
                                Widget? _,
                              ) {
                                if (!value) {
                                  return SliverToBoxAdapter(
                                    child: SizedBox.shrink(),
                                  );
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
                            SliverPadding(
                              padding: _mainScreenPadding.add(
                                EdgeInsets.only(
                                  top: UiConstant.spaceBetweenSection,
                                  bottom: UiConstant.spaceAtBottom,
                                ),
                              ),
                              sliver: ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _searchController,
                                builder: (context, _, _) {
                                  List<QuicksplitTransactionModel> filterData =
                                      splitData;
                                  if (state is QuicksplitFetchSuccess) {
                                    filterData = FilterSort.filteredSearchText(
                                      _searchController.text,
                                      splitData,
                                      (roomData) => roomData.description,
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
                                  int noOfCardsToBeShown = filterData.length;
                                  if (isWide) {
                                    noOfCardsToBeShown =
                                        (noOfCardsToBeShown / 2).toInt() +
                                        noOfCardsToBeShown % 2;
                                  }
                                  return SliverMainAxisGroup(
                                    slivers: [
                                      SliverList.builder(
                                        itemCount: noOfCardsToBeShown,
                                        itemBuilder: (
                                          BuildContext context,
                                          int index,
                                        ) {
                                          if (isWide) {
                                            QuicksplitTransactionModel
                                            eachSplitData =
                                                filterData[2 * index];
                                            return Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: QuickSplitCard(
                                                    data: eachSplitData,
                                                  ),
                                                ),
                                                Expanded(
                                                  child:
                                                      (index ==
                                                                  noOfCardsToBeShown -
                                                                      1 &&
                                                              filterData.length %
                                                                      2 >
                                                                  0)
                                                          ? SizedBox()
                                                          : QuickSplitCard(
                                                            data:
                                                                filterData[2 *
                                                                        index +
                                                                    1],
                                                          ),
                                                ),
                                              ],
                                            );
                                          } else {
                                            return QuickSplitCard(
                                              data: filterData[index],
                                            );
                                          }
                                        },
                                      ),
                                      genericFooterForDashboard(
                                        widget.isSearchEnabled,
                                        _builderFooter,
                                        context,
                                        state,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                );
              },
            ),
          ),
          floatingActionButton: CustomButton.customFloatingButton(
            Iconsax.add_copy,
            () {
              context.push(RouterConstants.quickSplitAddExpenseRouteName);
            },
          ),
        );
      },
    );
  }
}
