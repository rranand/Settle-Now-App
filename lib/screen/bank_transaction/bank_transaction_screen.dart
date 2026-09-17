import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/cubit/bank_transaction/bank_transaction_cubit.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/provider/provider_core.dart';
import 'package:settlenow/util/util_core.dart';

class BankTransactionScreen extends StatefulWidget {
  const BankTransactionScreen({super.key});

  @override
  State<BankTransactionScreen> createState() => _BankTransactionScreenState();
}

class _BankTransactionScreenState extends State<BankTransactionScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  UserModel _loggedInUser = UserModel.empty();

  // ValueNotifier to track the SMS permission status
  // 0: Not checked, 1: Granted, 2: Denied
  final ValueNotifier<int> isSmsPermissionGranted = ValueNotifier<int>(0);
  final ValueNotifier<bool> isSearchEnabled = ValueNotifier<bool>(false);
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _gridViewScrollController = ScrollController();

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
    isSmsPermissionGranted.dispose();
    super.dispose();
  }

  Future<void> _checkSmsPermission() async {
    final isGranted = await Permission.sms.isGranted;

    if (!mounted) return;

    if (isGranted) {
      isSmsPermissionGranted.value = 1;
      context.read<BankTransactionCubit>().fetchData();

      addPaginationListener<BankTransactionCubit, BankTransactionState>(
        scrollController: _gridViewScrollController,
        context: context,
        hasMore:
            (state) => state is BankTransactionSuccess && state.hasMoreData,
        isLoadingMore:
            (state) => state is BankTransactionSuccess && state.isLoadingMore,
        onFetch: () => context.read<BankTransactionCubit>().fetchData(),
      );
    } else {
      isSmsPermissionGranted.value = 2;
    }
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;
      _checkSmsPermission();
    }
  }

  Future<void> onRefresh() async {
    if (!_loggedInUser.hasData) {
      showNormalSnackBar(
        context,
        SnackbarMessageConstant.sessionExpiredMessage,
      );
      return;
    }
    context.read<BankTransactionCubit>().fetchData(forceRefresh: true);
  }

  void _blocListenerHandler(BuildContext context, BankTransactionState state) {
    if (state is BankTransactionFailure) {
      showNormalSnackBar(context, state.error);
    }
  }

  Widget _builderFooter(BuildContext context, BankTransactionState state) {
    if (state is BankTransactionSuccess) {
      return buildFooter(context, state.isLoadingMore, state.hasMoreData);
    }

    return const SizedBox.shrink();
  }

  List<BankTransactionModel> generateShimmerData() {
    return List.generate(10, (i) => BankTransactionModel.empty());
  }

  Widget transactionCardDisplay(List<BankTransactionModel> data) {
    bool isWide = MediaQuery.of(context).size.width > UiConstant.maxWidth;
    int noOfCardsToBeShown = data.length;

    if (isWide) {
      noOfCardsToBeShown =
          (noOfCardsToBeShown / 2).toInt() + noOfCardsToBeShown % 2;
    }
    return SliverList.builder(
      itemCount: noOfCardsToBeShown,
      itemBuilder: (context, index) {
        if (isWide) {
          final eachData = data[2 * index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: BankTransactionCard(data: eachData)),
              Expanded(
                child:
                    (index == noOfCardsToBeShown - 1 && data.length % 2 > 0)
                        ? SizedBox()
                        : BankTransactionCard(data: data[2 * index + 1]),
              ),
            ],
          );
        } else {
          return BankTransactionCard(data: data[index], onAddPressed: () {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isSmsPermissionGranted,
      builder: (context, _, child) {
        if (isSmsPermissionGranted.value == 2) {
          return SMSPermissionCard();
        }

        return BlocConsumer<BankTransactionCubit, BankTransactionState>(
          listener: _blocListenerHandler,
          builder: (context, state) {
            bool isLoaded = false;
            List<BankTransactionModel> bankTransactionData = [];

            if (state is! BankTransactionLoading &&
                state is! BankTransactionInitial) {
              isLoaded = true;
            }

            if (state is BankTransactionSuccess) {
              bankTransactionData = state.data;
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text("Bank Transactions"),
                titleSpacing: _mainScreenPadding.left,
                centerTitle: false,
                leading: appBarBackButton(context),
                actions:
                    isLoaded && bankTransactionData.isNotEmpty
                        ? appBarActionButton(context, [
                          InkWell(
                            borderRadius: BorderRadius.circular(
                              UiConstant.cardBorderRadius,
                            ),
                            child: Icon(Icons.search),
                            onTap: () {
                              isSearchEnabled.value = !isSearchEnabled.value;
                            },
                          ),
                        ])
                        : null,
              ),
              body: RefreshIndicator(
                onRefresh: onRefresh,
                notificationPredicate: (ScrollNotification notification) {
                  return notification.depth == 0;
                },
                child: CustomScrollView(
                  controller: _gridViewScrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers:
                      isLoaded
                          ? bankTransactionData.isEmpty
                              ? [
                                SliverFillRemaining(
                                  child: freshMessageWidget(
                                    state is BankTransactionFailure
                                        ? FreshScreenMessageConstant
                                            .bankTransactionSMSPermissionIssue
                                        : FreshScreenMessageConstant
                                            .noBankTransactionDashboard,
                                  ),
                                ),
                              ]
                              : [
                                ValueListenableBuilder(
                                  valueListenable: isSearchEnabled,
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
                                          isSearchEnabled,
                                          _searchController,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                BlocConsumer<
                                  BankTransactionCubit,
                                  BankTransactionState
                                >(
                                  listener: _blocListenerHandler,
                                  builder: (context, state) {
                                    if (state is BankTransactionFailure) {
                                      return SliverFillRemaining(
                                        child: freshMessageWidget(
                                          FreshScreenMessageConstant
                                              .bankTransactionSMSPermissionIssue,
                                        ),
                                      );
                                    }

                                    if (bankTransactionData.isEmpty) {
                                      return SliverFillRemaining(
                                        child: freshMessageWidget(
                                          FreshScreenMessageConstant
                                              .noBankTransactionDashboard,
                                        ),
                                      );
                                    } else {
                                      return SliverPadding(
                                        padding: _mainScreenPadding.add(
                                          EdgeInsets.only(
                                            top: UiConstant.spaceBetweenSection,
                                            bottom: UiConstant.spaceAtBottom,
                                          ),
                                        ),
                                        sliver: ValueListenableBuilder<
                                          TextEditingValue
                                        >(
                                          valueListenable: _searchController,
                                          builder: (context, _, _) {
                                            List<BankTransactionModel>
                                            filterData = bankTransactionData;
                                            if (state
                                                is BankTransactionSuccess) {
                                              filterData =
                                                  FilterSort.filteredSearchText(
                                                    _searchController.text,
                                                    bankTransactionData,
                                                    (transactionData) {
                                                      String searchStr =
                                                          "${transactionData.receiver.toLowerCase()} ${transactionData.transactionID} ${transactionData.amount} ${transactionData.bank.label} ${transactionData.mode.label}";
                                                      return searchStr;
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
                                                transactionCardDisplay(
                                                  filterData,
                                                ),
                                                genericFooterForDashboard(
                                                  isSearchEnabled,
                                                  _builderFooter,
                                                  context,
                                                  state,
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ]
                          : [transactionCardDisplay(generateShimmerData())],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
