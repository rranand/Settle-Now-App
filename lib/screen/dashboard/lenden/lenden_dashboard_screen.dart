import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/bloc/lenden/lenden_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/model/lenden_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/card/lenden_card.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';

class LendenDashboardScreen extends StatefulWidget {
  final ValueNotifier<bool> isSearchEnabled;
  const LendenDashboardScreen({super.key, required this.isSearchEnabled});

  @override
  State<LendenDashboardScreen> createState() => _LendenDashboardScreenState();
}

class _LendenDashboardScreenState extends State<LendenDashboardScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  final TextEditingController _searchController = TextEditingController();

  void _blocListenerHandler(BuildContext context, LendenState state) {
    if (state is LendenFailure) {
      showNormalSnackBar(context, state.error);
    }
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
  void initState() {
    super.initState();
    final lendenDataFetched = context.read<LendenBloc>().state;

    if (!lendenDataFetched.hasData) {
      context.read<LendenBloc>().add(LendenFetch());
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
          BlocConsumer<LendenBloc, LendenState>(
            listener: _blocListenerHandler,
            builder: (context, state) {
              List<LendenModel> lendenData = [];
              if (state is LendenFetchSuccess) {
                lendenData = state.data;
              } else if (state is LendenLoading) {
                lendenData = List.generate(11, (i) => LendenModel.empty());
              }
              return SliverPadding(
                padding: _mainScreenPadding.add(
                  EdgeInsets.only(
                    top: UiConstant.spaceBetweenSection,
                    bottom: UiConstant.spaceAtBottom,
                  ),
                ),
                sliver: SliverGrid.builder(
                  itemCount: lendenData.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: cardSizeInfo[0],
                    mainAxisSpacing: UiConstant.spaceBetweenCard,
                    crossAxisSpacing: UiConstant.spaceBetweenCard,
                    childAspectRatio: cardSizeInfo[1],
                  ),
                  itemBuilder:
                      (context, index) => SizedBox(
                        width: cardSizeInfo[0],
                        child: LendenCard(data: lendenData[index]),
                      ),
                ),
              );
            },
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
