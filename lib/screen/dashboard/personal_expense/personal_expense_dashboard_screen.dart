import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
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
  late ScrollController _scrollController;
  UserModel _loggedInUser = UserModel.empty();

  void _blocListenerHandler(
    BuildContext context,
    PersonalExpenseDashboardState state,
  ) {
    if (state is PersonalExpenseDashboardFailure) {
      showNormalSnackBar(context, state.error);
    }
  }

  Widget monthWiseCardsWidget(
    List<PersonalExpenseInfoModel> monthlyPersonalTransaction,
  ) {
    monthlyPersonalTransaction.sort(
      (a, b) => CalenderConstant.getIndexOfMonth(
        a.monthName,
      ).compareTo(CalenderConstant.getIndexOfMonth(b.monthName)),
    );
    return SliverPadding(
      padding: _mainScreenPadding,
      sliver: SliverGrid.builder(
        itemCount: monthlyPersonalTransaction.length,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: cardSizeInfo[0],
          mainAxisSpacing: UiConstant.spaceBetweenCard,
          crossAxisSpacing: UiConstant.spaceBetweenCard,
          childAspectRatio: cardSizeInfo[1],
        ),
        itemBuilder: (BuildContext context, int index) {
          return PersonalExpenseCard(data: monthlyPersonalTransaction[index]);
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
    _scrollController = ScrollController();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;

      final state = context.read<PersonalExpenseDashboardBloc>().state;
      if (state is! PersonalExpenseDashboardFetchSuccess) {
        context.read<PersonalExpenseDashboardBloc>().add(
          PersonalExpenseDashboardFetch(alreadyHave: 0),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      PersonalExpenseDashboardFetch(alreadyHave: 0),
    );
  }

  List<int> filterYearDataByPreference(
    Map<int, List<PersonalExpenseInfoModel>> oldData,
    EmptyPreferenceSection pref,
  ) {
    if (pref.showEmpty) {
      return oldData.keys.toList();
    }

    List<int> oldYears = oldData.keys.toList();

    List<int> data = [];

    for (int i = 0; i < oldYears.length; i++) {
      if (DateTime.now().year == oldYears[i]) {
        data.add(DateTime.now().year);
        continue;
      }
      List<PersonalExpenseInfoModel> monthlyPersonalTransaction =
          oldData[oldYears[i]]!;

      for (int j = 0; j < monthlyPersonalTransaction.length; j++) {
        if (monthlyPersonalTransaction[j].amount > 0) {
          data.add(int.parse(monthlyPersonalTransaction[j].year));
          break;
        }
      }
    }

    return data;
  }

  List<PersonalExpenseInfoModel> filterMonthDataByPreference(
    int year,
    List<PersonalExpenseInfoModel> oldData,
    EmptyPreferenceSection pref,
  ) {
    if (pref.showEmpty) {
      return oldData;
    }

    List<PersonalExpenseInfoModel> data = [];

    for (int i = 0; i < oldData.length; i++) {
      int monthIndex =
          CalenderConstant.getIndexOfMonth(oldData[i].monthName) + 1;

      if (oldData[i].amount > 0 ||
          (DateTime.now().year == year && monthIndex == DateTime.now().month)) {
        data.add(oldData[i]);
      }
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferenceProvider>(
      builder: (context, prefData, _) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: onRefresh,
            notificationPredicate: (ScrollNotification notification) {
              final state = context.read<PersonalExpenseDashboardBloc>().state;
              if (state is PersonalExpenseDashboardFetchSuccess &&
                  state.data.isNotEmpty) {
                return notification.depth == 0;
              } else {
                // When there's no data, allow refresh from the main scroll view
                return notification.depth == 1;
              }
            },
            child: BlocConsumer<
              PersonalExpenseDashboardBloc,
              PersonalExpenseDashboardState
            >(
              listener: _blocListenerHandler,
              builder: (context, state) {
                List<int> years = [DateTime.now().year];
                if (state is PersonalExpenseDashboardFetchSuccess) {
                  years = filterYearDataByPreference(
                    state.data,
                    prefData.personalExpensePref,
                  );
                  years.sort((a, b) => a.compareTo(b));

                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients &&
                        _scrollController.position.hasContentDimensions) {
                      _scrollController.jumpTo(
                        _scrollController.position.maxScrollExtent,
                      );
                    }
                  });
                }

                return CustomScrollView(
                  controller: _scrollController,
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
                    years.isEmpty
                        ? SliverToBoxAdapter(
                          child: noRecordFoundWidget(
                            "No Personal Expense Found",
                            context,
                          ),
                        )
                        : SliverToBoxAdapter(child: SizedBox.shrink()),
                    ...List.generate(years.length, (index) {
                      List<PersonalExpenseInfoModel>
                      monthlyPersonalTransaction = [];
                      if (state is PersonalExpenseDashboardFetchSuccess) {
                        monthlyPersonalTransaction =
                            filterMonthDataByPreference(
                              years[index],
                              state.data[years[index]]!,
                              prefData.personalExpensePref,
                            );
                      } else {
                        monthlyPersonalTransaction = List.filled(
                          12,
                          PersonalExpenseInfoModel.empty(),
                        );
                      }
                      return SliverStickyHeader.builder(
                        sticky: false,
                        builder: (context, state) {
                          return Container(
                            margin: _mainScreenPadding,
                            padding: EdgeInsets.symmetric(
                              vertical: .5 * UiConstant.spaceBetweenSection,
                            ),
                            child: Row(
                              children: [
                                Expanded(child: SizedBox()),
                                SizedBox(
                                  width: 80,
                                  child: GradientWidget(
                                    text: years[index].toString(),
                                    gradientColors:
                                        GradientColorConstant.tealToGreen,
                                    textSize: 16,
                                    textColor: Colors.white,
                                  ),
                                ),
                                Expanded(child: SizedBox()),
                              ],
                            ),
                          );
                        },
                        sliver: monthWiseCardsWidget(
                          monthlyPersonalTransaction,
                        ),
                      );
                    }),
                    SliverPadding(
                      padding: EdgeInsets.only(
                        bottom: UiConstant.spaceAtBottom,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          floatingActionButton: BlocBuilder<
            PersonalExpenseDashboardBloc,
            PersonalExpenseDashboardState
          >(
            builder: (context, state) {
              if (state is PersonalExpenseDashboardFetchSuccess) {
                DateTime now = DateTime.now();
                int year = now.year;
                int month = now.month - 1;

                PersonalExpenseInfoModel currentMonthPersonalExpense =
                    (state.data[year] ?? []).firstWhere(
                      (ele) =>
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
