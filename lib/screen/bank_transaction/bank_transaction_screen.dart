import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;
      context.read<BankTransactionCubit>().fetchData();
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
    context.read<BankTransactionCubit>().fetchData(refresh: true);
  }

  void _blocListenerHandler(BuildContext context, BankTransactionState state) {
    if (state is BankTransactionFailure) {
      showNormalSnackBar(context, state.error);
    }
  }

  Widget _builderFooter(BuildContext context, BankTransactionState state) {
    if (state is BankTransactionSuccess) {
      return buildFooter(context, false, false);
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final cardSizeInfo = calculateCrossAspectRatio(
      context,
      MediaQuery.of(context).size.width,
      _mainScreenPadding,
      cardHeight: UiConstant.cardFixedHeight + 10,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Bank Transactions")),
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
              valueListenable: isSearchEnabled,
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
                      isSearchEnabled,
                      _searchController,
                    ),
                  ),
                );
              },
            ),
            BlocConsumer<BankTransactionCubit, BankTransactionState>(
              listener: _blocListenerHandler,
              builder: (context, state) {
                List<BankTransactionModel> bankTransactionData = [];
                List<Bank> bankNameFound = [];
                List<PaymentMode> transactionMode = [];

                if (state is BankTransactionSuccess) {
                  bankTransactionData = state.data;
                  bankNameFound = state.banks;
                  transactionMode = state.paymentModes;
                } else if (state is BankTransactionLoading) {
                  bankTransactionData = List.generate(
                    11,
                    (i) => BankTransactionModel.empty(),
                  );
                } else if (state is BankTransactionFailure) {
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
                      FreshScreenMessageConstant.noBankTransactionDashboard,
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
                    sliver: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _searchController,
                      builder: (context, _, _) {
                        List<BankTransactionModel> filterData =
                            bankTransactionData;
                        if (state is BankTransactionSuccess) {
                          filterData = FilterSort.filteredSearchText(
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
                            SliverGrid.builder(
                              itemCount: filterData.length,
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: cardSizeInfo[0],
                                    mainAxisSpacing:
                                        UiConstant.spaceBetweenCard,
                                    crossAxisSpacing:
                                        UiConstant.spaceBetweenCard,
                                    childAspectRatio: cardSizeInfo[1],
                                  ),
                              itemBuilder:
                                  (context, index) => SizedBox(
                                    width: cardSizeInfo[0],
                                    child: BankTransactionCard(
                                      data: filterData[index],
                                      onTap: () {},
                                    ),
                                  ),
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
          ],
        ),
      ),
    );
  }
}
