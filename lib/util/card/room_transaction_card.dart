import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class RoomTransactionCard extends StatefulWidget {
  final int index;
  const RoomTransactionCard({super.key, required this.index});

  @override
  State<RoomTransactionCard> createState() => _RoomTransactionCardState();
}

class _RoomTransactionCardState extends State<RoomTransactionCard> {
  final double amount = -100;
  final ValueNotifier<bool> isExpanded = ValueNotifier(false);
  final List<String> tagsTitle = ["Edited"];
  bool _isManualSplit = false;

  @override
  void initState() {
    super.initState();
    if (widget.index % 2 == 0) {
      _isManualSplit = true;
      tagsTitle.add("Partial");
    }
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
            UserModel user = UiConstant.users[index % UiConstant.users.length];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      overlapUserImageWidget(context, [user], 1),
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
              ),
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
                  tagOnCard("Food"),
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
              Visibility(
                visible: _isManualSplit,
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    UiConstant.cardBorderRadius,
                  ),
                  child: Icon(Iconsax.info_circle, color: Colors.grey),
                  onTap: () {
                    isExpanded.value = !isExpanded.value;
                  },
                ),
              ),
            ],
          ),
          ListTile(
            leading: colouredIcon(
              Icon(
                CategoryParser.expenseCategoryIcons[widget.index %
                    CategoryParser.expenseCategoryIcons.length],
              ),
              UiConstant.colorsWithShade100[widget.index %
                  CategoryParser.expenseCategoryIcons.length],
            ),
            title: Text("Chickoo Ice-Cream"),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                subTextOnCard("Created On March 10, 2025"),
                widget.index % 3 == 0
                    ? subTextOnCard("Modified On March 12, 2025")
                    : subTextOnCard(""),
              ],
            ),
            trailing: Text(
              formatCurrency((121 + Random().nextInt(300)) * 1.0, context),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
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
