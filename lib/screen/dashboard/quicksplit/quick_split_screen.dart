import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/card/quick_split_card.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';

class QuickSplitScreen extends StatefulWidget {
  final ValueNotifier<bool> isSearchEnabled;
  const QuickSplitScreen({super.key, required this.isSearchEnabled});

  @override
  State<QuickSplitScreen> createState() => _QuickSplitScreenState();
}

class _QuickSplitScreenState extends State<QuickSplitScreen> {
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
      body: Column(
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
            child: ListView.separated(
              padding: _mainScreenPadding.add(
                EdgeInsets.only(
                  top: UiConstant.spaceBetweenSection,
                  bottom: 2 * UiConstant.spaceBetweenSection,
                ),
              ),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return QuickSplitCard();
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: .5 * UiConstant.spaceBetweenSection);
              },
              itemCount: 20,
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
