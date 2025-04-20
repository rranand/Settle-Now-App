import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/constant/home_ui_constant.dart';
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
  final ValueNotifier<bool> isExpanded = ValueNotifier(false);
  final List<String> tagsTitle = ["Edited"];

  Widget transactionInfoWidget(bool value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: !value,
          child: const SizedBox(height: UiConstant.cardSpaceAfterSubText),
        ),
        Visibility(
          visible: !value,
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
          visible: !value,
          child: const SizedBox(height: UiConstant.cardSpaceAfterSubText),
        ),
        subTextOnCard("Created By Rohit Anand"),
        subTextOnCard("Created On March 10, 2025"),
        Visibility(
          visible: value,
          child: subTextOnCard("Modified On June 10, 2025"),
        ),
      ],
    );
  }

  Widget extendedTransactionWidget() {
    return Column(
      children: [
        Divider(),
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(UiConstant.cardPadding),
      margin: EdgeInsets.all(4),
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  tagOnCard(expenseCategories[0]),
                  ...List.generate(
                    tagsTitle.length,
                    (index) => tagOnCard(
                      tagsTitle[index],
                      textColor: UiConstant.colors[1],
                      backgroundColor: UiConstant.colorsWithShade50[1],
                    ),
                  ),
                ],
              ),
              InkWell(
                child: Icon(Iconsax.info_circle, color: Colors.grey),
                onTap: () {
                  isExpanded.value = !isExpanded.value;
                },
              ),
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
                        ValueListenableBuilder(
                          valueListenable: isExpanded,
                          builder: (
                            BuildContext context,
                            bool value,
                            Widget? child,
                          ) {
                            return transactionInfoWidget(value);
                          },
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
          ValueListenableBuilder(
            valueListenable: isExpanded,
            builder: (context, value, child) {
              if (value) {
                return child!;
              } else {
                return SizedBox.shrink();
              }
            },
            child: extendedTransactionWidget(),
          ),
        ],
      ),
    );
  }
}
