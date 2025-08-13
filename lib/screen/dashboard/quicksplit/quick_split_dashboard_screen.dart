import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/quicksplit/quicksplit_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/model/preference_model.dart';
import 'package:settlenow_v2/model/transaction_model.dart';
import 'package:settlenow_v2/model/user_amount_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/provider/preference_provider.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/card/quick_split_card.dart';
import 'package:settlenow_v2/util/handler/filter_sort.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

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

  void _blocListenerHandler(BuildContext context, QuicksplitState state) {
    if (state is QuicksplitFailure) {
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
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;

      final state = context.read<QuicksplitBloc>().state;

      if (state is! QuicksplitFetchSuccess) {
        context.read<QuicksplitBloc>().add(
          QuicksplitFetch(_loggedInUser.authToken),
        );
      }
    }

    widget.isSearchEnabled.addListener(() {
      _searchController.text = "";
    });
  }

  Future<void> onRefresh() async {
    if (!_loggedInUser.hasData) {
      showNormalSnackBar(context, "Please re-login...Session expired!");
      return;
    }
    context.read<QuicksplitBloc>().add(
      QuicksplitFetch(_loggedInUser.authToken),
    );
  }

  List<TransactionModel> filterDataByPreference(
    List<TransactionModel> oldData,
    PreferenceSection pref,
  ) {
    if (pref.isSettled) {
      return oldData;
    }

    List<TransactionModel> data = [];

    for (int i = 0; i < oldData.length; i++) {
      bool isSettledByYou = false;
      if (oldData[i].createdBy.id == _loggedInUser.id) {
        isSettledByYou = oldData[i].createdBy.isSettled;
      } else {
        isSettledByYou =
            oldData[i].users
                .firstWhere(
                  (ele) => ele.id == _loggedInUser.id,
                  orElse: () => UserAmountModel.empty(),
                )
                .isSettled;
      }

      if (pref.isSettled != isSettledByYou) {
        continue;
      }
      data.add(oldData[i]);
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width > UiConstant.maxWidth;

    return Consumer<PreferenceProvider>(
      builder: (context, prefData, _) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: onRefresh,
            child: BlocConsumer<QuicksplitBloc, QuicksplitState>(
              listener: _blocListenerHandler,
              builder: (context, state) {
                List<TransactionModel> splitData = [];
                if (state is QuicksplitFetchSuccess) {
                  splitData = filterDataByPreference(
                    state.data,
                    prefData.quicksplitPref,
                  );
                } else if (state is QuicksplitLoading) {
                  splitData = List.generate(
                    11,
                    (i) => TransactionModel.empty(),
                  );
                }

                if (splitData.isEmpty) {
                  return noRecordFoundWidget("No Transaction Found", context);
                } else {
                  return CustomScrollView(
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
                              backgroundColor: Colors.white,
                              surfaceTintColor: Colors.white,
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
                            List<TransactionModel> filterData = splitData;
                            if (state is QuicksplitFetchSuccess) {
                              filterData = FilterSort.filteredSearchText(
                                _searchController.text,
                                splitData,
                                (roomData) => roomData.description,
                              );
                            }

                            if (filterData.isEmpty) {
                              return SliverToBoxAdapter(
                                child: noRecordFoundWidget(
                                  "No Matching Records",
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
                            return SliverList.builder(
                              itemCount: noOfCardsToBeShown,
                              itemBuilder: (BuildContext context, int index) {
                                TransactionModel eachSplitData =
                                    filterData[index];
                                if (isWide) {
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
                                            (index == noOfCardsToBeShown - 1 &&
                                                    filterData.length % 2 > 0)
                                                ? SizedBox()
                                                : QuickSplitCard(
                                                  data:
                                                      filterData[2 * index + 1],
                                                ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return QuickSplitCard(data: eachSplitData);
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
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
