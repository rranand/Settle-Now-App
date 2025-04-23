import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/card/lenden_card.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';

class LendenDashboardScreen extends StatefulWidget {
  final ValueNotifier<bool> isSearchEnabled;
  const LendenDashboardScreen({super.key, required this.isSearchEnabled});

  @override
  State<LendenDashboardScreen> createState() => _LendenDashboardScreenState();
}

class _LendenDashboardScreenState extends State<LendenDashboardScreen> {
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
    final cardSizeInfo = calculateCrossAspectRatio(
      MediaQuery.of(context).size.width,
      _mainScreenPadding,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
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
          ),
          SliverPadding(
            padding: _mainScreenPadding.add(
              EdgeInsets.only(
                top: UiConstant.spaceBetweenSection,
                bottom: UiConstant.spaceAtBottom,
              ),
            ),
            sliver: SliverGrid.builder(
              itemCount: 11,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: cardSizeInfo[0],
                mainAxisSpacing: UiConstant.spaceBetweenCard,
                crossAxisSpacing: UiConstant.spaceBetweenCard,
                childAspectRatio: cardSizeInfo[1],
              ),
              itemBuilder:
                  (context, index) => InkWell(
                    borderRadius: BorderRadius.circular(
                      UiConstant.cardBorderRadius,
                    ),
                    onTap: () {
                      context.push("${RouterConstants.lendenRouteName}/id");
                    },
                    child: SizedBox(
                      width: cardSizeInfo[0],
                      child: LendenCard(),
                    ),
                  ),
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
