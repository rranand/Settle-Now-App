import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/internationalization/currency.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/provider/provider_core.dart';
import 'package:settlenow/util/util_core.dart';

class RoomUserScreen extends StatefulWidget {
  const RoomUserScreen({super.key});

  @override
  State<RoomUserScreen> createState() => _RoomUserScreenState();
}

class _RoomUserScreenState extends State<RoomUserScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  final double subTextFontSize = UiConstant.cardTitleTextSize - 3;

  Color? getAmountColor(double amount) {
    amount = getPrecisedAmount(amount);

    if (amount == 0) {
      return Colors.grey;
    }

    return amount < 0 ? Colors.red : Colors.green;
  }

  Widget _userExpenseWidget(RoomUserModel data, double amount) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(UiConstant.cardPadding + 2),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
          boxShadow: getContainerBoxShadow(context),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                data.hasData
                    ? overlapUserImageWidget(
                      context,
                      [data],
                      1,
                      imageRadius: 55,
                    )
                    : CustomShimmerEffect.overlapImageWidget(
                      context,
                      noOfImages: 1,
                      imageRadius: 55,
                    ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    data.hasData
                        ? Text(
                          data.name,
                          style: TextStyle(
                            fontSize: UiConstant.cardTitleTextSize,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                        : CustomShimmerEffect.textWidget(
                          context,
                          fontSize: UiConstant.cardTitleTextSize,
                          width: 150,
                        ),
                    subTextOnCard(
                      "Contributed: ${formatCurrency(data.contribution, context)}",
                      context,
                      fontSize: subTextFontSize,
                      isLoaded: data.hasData,
                    ),
                    subTextOnCard(
                      "Spent: ${formatCurrency(data.spent, context)}",
                      context,
                      fontSize: subTextFontSize,
                      isLoaded: data.hasData,
                    ),
                    subTextOnCard(
                      "Balance: ${formatCurrency(amount, context)}",
                      context,
                      fontSize: subTextFontSize,
                      textColor: getAmountColor(amount),
                      isLoaded: data.hasData,
                    ),
                  ],
                ),
              ],
            ),
            Visibility(
              visible: data.hasData,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                decoration: BoxDecoration(
                  color:
                      data.active ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  data.active ? "Active" : "Closed",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: data.active ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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

  Widget showUserExpenseInfo(
    List<RoomUserModel> data,
    Map<String, double> balanceMap,
  ) {
    final cardSizeInfo = calculateCrossAspectRatio(
      context,
      MediaQuery.of(context).size.width,
      _mainScreenPadding,
      cardHeight: 135,
    );
    return SliverGrid.builder(
      itemCount: data.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: cardSizeInfo[0],
        mainAxisSpacing: UiConstant.spaceBetweenCard,
        crossAxisSpacing: UiConstant.spaceBetweenCard,
        childAspectRatio: cardSizeInfo[1],
      ),
      itemBuilder: (BuildContext context, int index) {
        double amount = balanceMap[data[index].id] ?? 0;
        return _userExpenseWidget(data[index], amount);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomUserCubit, RoomUserState>(
      builder: (context, state) {
        List<RoomUserModel> data = [];
        Map<String, double> balanceMap = {};

        if (state is RoomUserSuccess) {
          data = state.data;

          for (int i = 0; i < data.length; i++) {
            balanceMap[data[i].id] =
                data[i].contribution - data[i].spent + data[i].settle;
          }

          if (data.isEmpty) {
            return SliverToBoxAdapter(
              child: noRecordFoundWidget(
                "Something went wrong, Refresh!",
                context,
              ),
            );
          }

          return BlocBuilder<FilterCubit, FilterState>(
            builder: (context, filterState) {
              bool haveFilter = filterState.isFilterApplied;
              if (haveFilter) {
                data = calculateUserExpenseInfo(
                  state.data,
                  filterState.data.cast<RoomTransactionModel>(),
                  [],
                );
              } else {
                data = state.data;
              }
              return showUserExpenseInfo(data, balanceMap);
            },
          );
        } else {
          return showUserExpenseInfo(
            List.filled(11, RoomUserModel.empty()),
            balanceMap,
          );
        }
      },
    );
  }
}
