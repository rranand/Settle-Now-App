import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/card/quick_split_card.dart';
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
                "Search Transaction",
                widget.isSearchEnabled,
                _searchController,
                (value) {
                  // Add filter logic if needed
                },
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= UiConstant.maxWidth;
                  final cardWidth =
                      isWide
                          ? (constraints.maxWidth / 2) -
                              UiConstant.spaceBetweenCard -
                              _mainScreenPadding.left
                          : constraints.maxWidth;
                  return SingleChildScrollView(
                    padding: _mainScreenPadding.add(
                      EdgeInsets.only(
                        top: UiConstant.spaceBetweenSection,
                        bottom: 2 * UiConstant.spaceBetweenSection,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(right: isWide ? 8.0 : 0),
                      child: Wrap(
                        spacing: UiConstant.spaceBetweenCard,
                        runSpacing: UiConstant.spaceBetweenCard,
                        children: List.generate(
                          11,
                          (index) => SizedBox(
                            width: cardWidth,
                            child: QuickSplitCard(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CustomButton.customFloatingButton(
        Iconsax.add,
        () {},
      ),
    );
  }
}
