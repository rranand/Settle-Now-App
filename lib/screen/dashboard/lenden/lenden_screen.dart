import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/card/lenden_card.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';

class LendenScreen extends StatefulWidget {
  final ValueNotifier<bool> isSearchEnabled;
  const LendenScreen({super.key, required this.isSearchEnabled});

  @override
  State<LendenScreen> createState() => _LendenScreenState();
}

class _LendenScreenState extends State<LendenScreen> {
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
              "Search Len-Den",
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
              itemCount: 20,
              itemBuilder: (context, index) {
                return LendenCard();
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: .5 * UiConstant.spaceBetweenSection);
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
