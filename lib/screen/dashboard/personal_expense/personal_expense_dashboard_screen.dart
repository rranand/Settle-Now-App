import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:settlenow_v2/constant/calender_constant.dart';
import 'package:settlenow_v2/constant/gradient_color_constant.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/card/personal_expense_card.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= UiConstant.maxWidth;
        final cardWidth =
            isWide
                ? constraints.maxWidth
                : (constraints.maxWidth / 2) -
                    UiConstant.spaceBetweenCard -
                    _mainScreenPadding.left;
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: UiConstant.spaceBetweenCard,
          runSpacing: UiConstant.spaceBetweenCard,
          children: List.generate(
            months.length,
            (index) => SizedBox(
              width: cardWidth,
              height: 160,
              child: PersonalExpenseCard(monthName: months[index]),
            ),
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Padding(
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
            Expanded(
              child: CustomScrollView(
                shrinkWrap: true,
                slivers: List.generate(
                  years.length,
                  (index) => SliverStickyHeader.builder(
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
                              gradientColors:
                                  state.isPinned
                                      ? GradientColorConstant.tealToGreen
                                      : GradientColorConstant.coolIndigoToBlue,
                              textSize: 18,
                              textColor: Colors.white,
                            ),
                            Expanded(child: SizedBox()),
                          ],
                        ),
                      );
                    },

                    sliver: SliverToBoxAdapter(
                      child: monthWiseCardsWidget(CalenderConstant.monthName),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
