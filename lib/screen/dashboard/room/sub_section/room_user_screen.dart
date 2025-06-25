import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/cubit/room/room_user/room_user_cubit.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/model/room_user_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';
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

  Widget _userExpenseWidget(RoomUserModel data) {
    UserModel user = data.user;
    double amount = data.contribution - data.spent + data.settle;

    return Card(
      elevation: UiConstant.cardElevation,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(UiConstant.cardPadding + 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            data.hasData
                ? overlapUserImageWidget(context, [user], 1, imageRadius: 55)
                : CustomShimmerEffect.overlapImageWidget(
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
                      fontSize: UiConstant.cardTitleTextSize,
                      width: 150,
                    ),
                subTextOnCard(
                  "Contributed: ${formatCurrency(data.contribution, context)}",
                  fontSize: subTextFontSize,
                  isLoaded: data.hasData,
                ),
                subTextOnCard(
                  "Spent: ${formatCurrency(data.spent, context)}",
                  fontSize: subTextFontSize,
                  isLoaded: data.hasData,
                ),
                subTextOnCard(
                  "Balance: ${formatCurrency(amount, context)}",
                  fontSize: subTextFontSize,
                  textColor: getAmountColor(amount),
                  isLoaded: data.hasData,
                ),
              ],
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

  @override
  Widget build(BuildContext context) {
    final cardSizeInfo = calculateCrossAspectRatio(
      MediaQuery.of(context).size.width,
      _mainScreenPadding,
      cardHeight: 135,
    );
    return BlocBuilder<RoomUserCubit, RoomUserState>(
      builder: (context, state) {
        List<RoomUserModel> data = [];

        if (state is RoomUserSuccess) {
          data = state.data;
        } else {
          data = List.filled(11, RoomUserModel.empty());
        }

        return SliverGrid.builder(
          itemCount: data.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: cardSizeInfo[0],
            mainAxisSpacing: UiConstant.spaceBetweenCard,
            crossAxisSpacing: UiConstant.spaceBetweenCard,
            childAspectRatio: cardSizeInfo[1],
          ),
          itemBuilder: (BuildContext context, int index) {
            return _userExpenseWidget(data[index]);
          },
        );
      },
    );
  }
}
