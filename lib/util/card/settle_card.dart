import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class SettleCard extends StatelessWidget {
  final double screenWidth;
  const SettleCard({super.key, required this.screenWidth});

  Widget _userCard(BuildContext context, bool isLast) {
    final userCardWidth = (screenWidth - 2 * UiConstant.cardPadding - 36) * .5;
    return SizedBox(
      width: userCardWidth,
      child: Row(
        mainAxisAlignment:
            isLast ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          overlapUserImageWidget(
            context,
            [UiConstant.memberAvatars[0]],
            1,
            imageRadius: 40,
          ),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              "Rohit Anand, Anand, Anand",
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {},
            borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
            backgroundColor: Color(0xFF5bc0de),
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) {},
            borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        elevation: UiConstant.cardElevation,
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.all(UiConstant.cardPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
            border: Border.all(color: Colors.grey.withAlpha(51)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _userCard(context, false),
                  Icon(Iconsax.arrow_right_14),
                  _userCard(context, true),
                ],
              ),
              SizedBox(height: UiConstant.spaceBetweenSection),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  formatCurrency(
                    (1111 + Random().nextInt(10000)).toDouble(),
                    context,
                  ),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              Divider(),
              subTextOnCard(
                convertDateTimeFormat(
                  DateTime.now().subtract(
                    Duration(hours: 11 + Random().nextInt(1000)),
                  ),
                ),
                fontSize: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
