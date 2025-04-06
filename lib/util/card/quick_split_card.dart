import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
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
  final bool isExpanded = true;

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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  tagOnCard("Food & Drink"),
                  SizedBox(width: 8),
                  tagOnCard(
                    "Edited",
                    textColor: Colors.green,
                    backgroundColor: Colors.green.shade50,
                  ),
                ],
              ),
              Icon(Iconsax.info_circle, color: Colors.grey),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: UiConstant.cardSpaceBetweenSubText,
                        ),
                        Text(
                          "Purchased a burger",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Visibility(
                          visible: !isExpanded,
                          child: const SizedBox(
                            height: UiConstant.cardSpaceAfterSubText,
                          ),
                        ),
                        Visibility(
                          visible: !isExpanded,
                          child: overlapUserImageWidget(
                            context,
                            UiConstant.memberAvatars,
                            4,
                            totalUsers: UiConstant.memberAvatars.length,
                            imageRadius: 30,
                            nextImageOffset: 24,
                          ),
                        ),
                        Visibility(
                          visible: !isExpanded,
                          child: const SizedBox(
                            height: UiConstant.cardSpaceAfterSubText,
                          ),
                        ),
                        subTextOnCard("Created By Rohit Anand"),
                        subTextOnCard("Created On March 10, 2025"),
                        Visibility(
                          visible: isExpanded,
                          child: subTextOnCard("Modified On June 10, 2025"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                formatCurrency(amount, context),
                style: TextStyle(
                  color: amount < 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Visibility(
            visible: isExpanded,
            child: Column(
              children: [
                Divider(),
                ListView.separated(
                  shrinkWrap: true,
                  itemCount: 3,
                  itemBuilder: (BuildContext context, int index) {
                    double memberAmount =
                        (100 + 10 * index) * (index % 2 == 0 ? -1 : 1);
                    String imgUrl =
                        UiConstant.memberAvatars[index %
                            UiConstant.memberAvatars.length];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            overlapUserImageWidget(context, [imgUrl], 1),
                            SizedBox(width: 8),
                            Text("Rohit Anand"),
                          ],
                        ),
                        Text(
                          formatCurrency(memberAmount, context),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: memberAmount < 0 ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(thickness: 0.3);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
