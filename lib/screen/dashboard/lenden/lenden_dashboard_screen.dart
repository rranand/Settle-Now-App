import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/card/lenden_card.dart';
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
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
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
                        bottom: UiConstant.spaceAtBottom,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(right: isWide ? 8.0 : 0),
                      child: Wrap(
                        spacing: UiConstant.spaceBetweenCard,
                        runSpacing: UiConstant.spaceBetweenCard,
                        children: List.generate(
                          11,
                          (index) => InkWell(
                            onTap: () {
                              context.push(
                                "${RouterConstants.lendenRouteName}/id",
                              );
                            },
                            child: SizedBox(
                              width: cardWidth,
                              child: LendenCard(),
                            ),
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
