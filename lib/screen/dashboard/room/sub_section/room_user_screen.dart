import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/cubit/filter/filter_cubit.dart';
import 'package:settlenow_v2/cubit/room/room_user/room_user_cubit.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/model/room_user_model.dart';
import 'package:settlenow_v2/model/transaction_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';
import 'package:settlenow_v2/util/functions/room_function.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class RoomUserScreen extends StatefulWidget {
  const RoomUserScreen({super.key});

  @override
  State<RoomUserScreen> createState() => _RoomUserScreenState();
}

class _RoomUserScreenState extends State<RoomUserScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  final double subTextFontSize = UiConstant.cardTitleTextSize - 3;

  Color? getAmountColor(double amount) {
    amount = (amount.abs() < 1e-2) ? 0 : amount;

    if (amount == 0) {
      return Colors.grey;
    }

    return amount < 0 ? Colors.red : Colors.green;
  }

  Widget _userExpenseWidget(RoomUserModel data, double amount) {
    UserModel user = data.user;

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
                      [user],
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
                          user.name,
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
        double amount = balanceMap[data[index].user.id] ?? 0;
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
            balanceMap[data[i].user.id] =
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
                  filterState.data.cast<TransactionModel>(),
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
