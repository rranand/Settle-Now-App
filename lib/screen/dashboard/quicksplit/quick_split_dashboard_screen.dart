import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/bloc/quicksplit/quicksplit_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/model/transaction_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/card/quick_split_card.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';

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

  void _blocListenerHandler(BuildContext context, QuicksplitState state) {
    if (state is QuicksplitFailure) {
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
    final state = context.read<QuicksplitBloc>().state;

    if (state is! QuicksplitFetchSuccess) {
      context.read<QuicksplitBloc>().add(QuicksplitFetch());
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width > UiConstant.maxWidth;

    return Scaffold(
      body: BlocConsumer<QuicksplitBloc, QuicksplitState>(
        listener: _blocListenerHandler,
        builder: (context, state) {
          List<TransactionModel> splitData = [];
          if (state is QuicksplitFetchSuccess) {
            splitData = state.data;
          } else if (state is QuicksplitLoading) {
            splitData = List.generate(11, (i) => TransactionModel.empty());
          }
          int noOfCardsToBeShown = splitData.length;
          if (isWide) {
            noOfCardsToBeShown =
                (noOfCardsToBeShown / 2).toInt() + noOfCardsToBeShown % 2;
          }
          return CustomScrollView(
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
              SliverPadding(
                padding: _mainScreenPadding.add(
                  EdgeInsets.only(
                    top: UiConstant.spaceBetweenSection,
                    bottom: UiConstant.spaceAtBottom,
                  ),
                ),
                sliver: SliverList.builder(
                  itemCount: noOfCardsToBeShown,
                  itemBuilder: (BuildContext context, int index) {
                    TransactionModel eachSplitData = splitData[index];
                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: QuickSplitCard(data: eachSplitData)),
                          Expanded(
                            child:
                                (index == noOfCardsToBeShown - 1 &&
                                        splitData.length % 2 > 0)
                                    ? SizedBox()
                                    : QuickSplitCard(
                                      data: splitData[2 * index + 1],
                                    ),
                          ),
                        ],
                      );
                    } else {
                      return QuickSplitCard(data: eachSplitData);
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: CustomButton.customFloatingButton(Iconsax.add, () {
        context.push(RouterConstants.quickSplitAddExpenseRouteName);
      }),
    );
  }
}
