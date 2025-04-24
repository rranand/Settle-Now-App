import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class RoomUserScreen extends StatefulWidget {
  final List<UserModel> users;
  const RoomUserScreen({super.key, required this.users});

  @override
  State<RoomUserScreen> createState() => _RoomUserScreenState();
}

class _RoomUserScreenState extends State<RoomUserScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  final double subTextFontSize = UiConstant.cardTitleTextSize - 3;

  Widget _userExpenseWidget(UserModel user) {
    UserModel user = widget.users.first;
    double amount = (111 + Random().nextInt(2000)).toDouble();

    if (amount % 2 == 0) {
      amount *= -1;
    }

    return Card(
      elevation: UiConstant.cardElevation,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(UiConstant.cardPadding + 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            overlapUserImageWidget(context, [user], 1, imageRadius: 55),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: UiConstant.cardTitleTextSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subTextOnCard(
                  "Contributed: ${formatCurrency(1200, context)}",
                  fontSize: subTextFontSize,
                ),
                subTextOnCard(
                  "Spent: ${formatCurrency(800, context)}",
                  fontSize: subTextFontSize,
                ),
                subTextOnCard(
                  "Balance: ${formatCurrency(amount, context)}",
                  fontSize: subTextFontSize,
                  textColor: amount < 0 ? Colors.red : Colors.green,
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
    return SliverGrid.builder(
      itemCount: widget.users.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: cardSizeInfo[0],
        mainAxisSpacing: UiConstant.spaceBetweenCard,
        crossAxisSpacing: UiConstant.spaceBetweenCard,
        childAspectRatio: cardSizeInfo[1],
      ),
      itemBuilder: (BuildContext context, int index) {
        return _userExpenseWidget(widget.users[index]);
      },
    );
  }
}
