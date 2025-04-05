import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/card/transaction_card.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';

class QuicksplitScreen extends StatefulWidget {
  final ValueNotifier<bool> isSearchEnabled;
  const QuicksplitScreen({super.key, required this.isSearchEnabled});

  @override
  State<QuicksplitScreen> createState() => _QuicksplitScreenState();
}

class _QuicksplitScreenState extends State<QuicksplitScreen> {
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
      body: Padding(
        padding: _mainScreenPadding,
        child: Column(
          children: [
            CustomFormField.searchBar(
              "Search Transaction...",
              widget.isSearchEnabled,
              _searchController,
              (value) {
                // Add filter logic if needed
              },
            ),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom:
                          index == 19 ? 2 * UiConstant.spaceBetweenSection : 0,
                      top: index == 0 ? UiConstant.spaceBetweenSection : 0,
                    ),
                    child: TransactionCard(),
                  );
                },
                separatorBuilder:
                    (context, index) => const SizedBox(height: 10),
                itemCount: 20,
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
