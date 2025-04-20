import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/card/quick_split_card.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';

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
  final List<int> tempArr = List.generate(11, (index) => index);

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
    final cardSizeInfo = calculateCrossAspectRatio(
      MediaQuery.of(context).size.width,
      _mainScreenPadding,
      cardHeight: UiConstant.cardFixedHeight + 15,
    );
    bool isWide = MediaQuery.of(context).size.width > UiConstant.maxWidth;
    int noOfCardsToBeShown = (tempArr.length / 2).toInt() + tempArr.length % 2;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: _mainScreenPadding,
              child: CustomFormField.searchBar(
                "Search Transaction",
                widget.isSearchEnabled,
                _searchController,
                (value) {
                  // Add filter logic if needed
                },
              ),
            ),
          ),
          SliverPadding(
            padding: _mainScreenPadding.add(
              EdgeInsets.only(
                top: UiConstant.spaceBetweenSection,
                bottom: UiConstant.spaceAtBottom,
              ),
            ),
            sliver: SliverList.builder(
              itemCount: isWide ? noOfCardsToBeShown : tempArr.length,
              itemBuilder: (BuildContext context, int index) {
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: QuickSplitCard(
                          screenPadding: _mainScreenPadding,
                          screenWidth: cardSizeInfo[0],
                        ),
                      ),
                      Expanded(
                        child:
                            (index == noOfCardsToBeShown - 1 &&
                                    tempArr.length % 2 > 0)
                                ? SizedBox()
                                : QuickSplitCard(
                                  screenPadding: _mainScreenPadding,
                                  screenWidth: cardSizeInfo[0],
                                ),
                      ),
                    ],
                  );
                } else {
                  return QuickSplitCard(
                    screenPadding: _mainScreenPadding,
                    screenWidth: cardSizeInfo[0],
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: CustomButton.customFloatingButton(
        Iconsax.add,
        () {},
      ),
    );
  }
}
