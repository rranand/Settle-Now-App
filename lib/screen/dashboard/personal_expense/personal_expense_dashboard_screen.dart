import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow_v2/constant/calender_constant.dart';
import 'package:settlenow_v2/constant/gradient_color_constant.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/card/personal_expense_card.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/gradient_widget.dart';

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

  final List<int> years = [2025, 2024, 2023];

  Widget monthWiseCardsWidget(List<String> months) {
    final cardSizeInfo = calculateCrossAspectRatio(
      MediaQuery.of(context).size.width,
      _mainScreenPadding,
      cardWidth: UiConstant.cardFixedHeight + 20,
      cardHeight: UiConstant.cardFixedHeight,
    );
    return SliverPadding(
      padding: _mainScreenPadding,
      sliver: SliverGrid.builder(
        itemCount: months.length,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: cardSizeInfo[0],
          mainAxisSpacing: UiConstant.spaceBetweenCard,
          crossAxisSpacing: UiConstant.spaceBetweenCard,
          childAspectRatio: cardSizeInfo[1],
        ),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              context.push("${RouterConstants.personalExpenseRouteName}/id");
            },
            child: PersonalExpenseCard(monthName: months[index]),
          );
        },
      ),
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: _mainScreenPadding,
              child: CustomFormField.searchBar(
                "Search",
                widget.isSearchEnabled,
                _searchController,
                (value) {
                  // Add filter logic if needed
                },
              ),
            ),
          ),
          ...List.generate(
            years.length,
            (index) => SliverStickyHeader.builder(
              builder: (context, state) {
                final double scrollPercent = state.scrollPercentage.clamp(
                  0.0,
                  1.0,
                );
                final int alpha =
                    (255 * (1.0 - scrollPercent)).clamp(0, 255).toInt();

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
                        gradientColors:
                            state.isPinned
                                ? GradientColorConstant.tealToGreen
                                : GradientColorConstant.coolIndigoToBlue
                                    .map((c) => c.withAlpha(alpha))
                                    .toList(),
                        textSize: 16,
                        textColor: Colors.white,
                      ),
                      Expanded(child: SizedBox()),
                    ],
                  ),
                );
              },
              sliver: monthWiseCardsWidget(CalenderConstant.monthName),
            ),
          ),
        ],
      ),
    );
  }
}
