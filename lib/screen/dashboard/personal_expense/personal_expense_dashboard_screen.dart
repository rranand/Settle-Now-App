import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:settlenow_v2/bloc/personal_expense/dashboard/personal_expense_dashboard_bloc.dart';
import 'package:settlenow_v2/constant/calender_constant.dart';
import 'package:settlenow_v2/constant/gradient_color_constant.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/model/personal_expense_info_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/card/personal_expense_card.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/gradient_widget.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';

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
      (a, b) => CalenderConstant.monthName
          .indexOf(a.monthName)
          .compareTo(CalenderConstant.monthName.indexOf(b.monthName)),
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
    final personalExpenseDataFetched =
        context.read<PersonalExpenseDashboardBloc>().state;
    if (!personalExpenseDataFetched.hasData) {
      context.read<PersonalExpenseDashboardBloc>().add(
        PersonalExpenseDashboardFetch(),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<
        PersonalExpenseDashboardBloc,
        PersonalExpenseDashboardState
      >(
        listener: _blocListenerHandler,
        builder: (context, state) {
          List<int> years = [DateTime.now().year];
          if (state is PersonalExpenseDashboardFetchSuccess) {
            years = state.data.keys.toList();
            years.sort((a, b) => a.compareTo(b));

            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
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
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.white,
                      title: CustomFormField.searchBar(
                        "Search",
                        widget.isSearchEnabled,
                        _searchController,
                        (value) {
                          // Add filter logic if needed
                        },
                      ),
                    ),
                  );
                },
              ),
              ...List.generate(
                years.length,
                (index) => SliverStickyHeader.builder(
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
                          GradientWidget(
                            text: "   ${years[index]}   ",
                            gradientColors: GradientColorConstant.tealToGreen,
                            textSize: 16,
                            textColor: Colors.white,
                          ),
                          Expanded(child: SizedBox()),
                        ],
                      ),
                    );
                  },
                  sliver: monthWiseCardsWidget(
                    state is! PersonalExpenseDashboardFetchSuccess
                        ? List.filled(12, PersonalExpenseInfoModel.empty())
                        : state.data[years[index]]!,
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(bottom: UiConstant.spaceAtBottom),
              ),
            ],
          );
        },
      ),
    );
  }
}
