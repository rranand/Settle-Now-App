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
                elevation: UiConstant.cardElevation,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              left: BorderSide(
                color: Color(0xFF14B8A6),
                width: UiConstant.cardBorderLeftSideStripWidth,
              ),
            ),
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
              const SizedBox(height: UiConstant.cardSpaceBetweenSubText),
              Text(
                "${amount < 0 ? "-" : "+"} ${formatCurrency(amount.abs(), context)}",
                style: TextStyle(
                  color: amount < 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: UiConstant.cardSpaceAfterSubText),
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
      ),
    );
  }
}
