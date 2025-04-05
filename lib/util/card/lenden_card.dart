import 'package:flutter/material.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class LendenCard extends StatelessWidget {
  final double amount = -100;
  const LendenCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Trip to Bhushan",
              style: const TextStyle(
                fontSize: UiConstant.cardTitleTextSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${amount < 0 ? "-" : "+"} ${formatCurrency(amount.abs(), context)}",
              style: TextStyle(
                color: amount < 0 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                overlapUserImageWidget(
                  context,
                  UiConstant.memberAvatars.sublist(0, 2),
                  UiConstant.memberAvatars.sublist(0, 2).length,
                  totalUsers: UiConstant.memberAvatars.sublist(0, 2).length,
                  imageRadius: 30,
                  nextImageOffset: 24,
                ),
                dateOnCard("March 15, 2023"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
