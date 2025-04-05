import 'package:flutter/material.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class QuickSplitCard extends StatefulWidget {
  const QuickSplitCard({super.key});

  @override
  State<QuickSplitCard> createState() => _QuickSplitCardState();
}

class _QuickSplitCardState extends State<QuickSplitCard> {
  final double amount = -100;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
        border: Border.all(color: Colors.grey.withAlpha(51)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: subTextOnCard(
                        "Food & Drink",
                        textColor: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UiConstant.cardSpaceBetweenSubText),
                    Text(
                      "Purchased a burger",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: UiConstant.cardSpaceAfterSubText),
                    overlapUserImageWidget(
                      context,
                      UiConstant.memberAvatars,
                      4,
                      totalUsers: UiConstant.memberAvatars.length,
                      imageRadius: 30,
                      nextImageOffset: 24,
                    ),
                    const SizedBox(height: UiConstant.cardSpaceAfterSubText),
                    subTextOnCard("Rohit Anand • March 10, 2025"),
                  ],
                ),
              ],
            ),
          ),
          Text(
            "${amount < 0 ? "-" : "+"} ${formatCurrency(amount.abs(), context)}",
            style: TextStyle(
              color: amount < 0 ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
