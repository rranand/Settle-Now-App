import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class RoomTransactionCard extends StatefulWidget {
  final TransactionModel data;
  const RoomTransactionCard({super.key, required this.data});

  @override
  State<RoomTransactionCard> createState() => _RoomTransactionCardState();
}

class _RoomTransactionCardState extends State<RoomTransactionCard> {
  final double amount = -100;
  final ValueNotifier<bool> isExpanded = ValueNotifier(false);
  bool _isManualSplit = false;

  List<String> createTags() {
    List<String> tags = [widget.data.category];
    if (widget.data.hasData) {
      if (widget.data.createdOn != widget.data.modifiedOn) {
        tags.add("Edited");
      }
      if (widget.data.users.isEmpty &&
          widget.data.createdBy.amount == widget.data.amount) {
        tags.add("Self");
      } else if (widget.data.users.isNotEmpty) {
        tags.add("Partial");
      }
    }
    return tags;
  }

  @override
  void initState() {
    super.initState();
    if (widget.data.users.isNotEmpty) {
      _isManualSplit = true;
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
    List<String> tags = createTags();
    int categoryIndex = CategoryParser.indexOfCategory(widget.data.category);
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
                children: List.generate(
                  tags.length,
                  (index) => tagOnCard(
                    tags[index],
                    textColor:
                        UiConstant.colors[index % UiConstant.colors.length],
                    backgroundColor:
                        UiConstant.colorsWithShade50[index %
                            UiConstant.colors.length],
                    isLoaded: widget.data.hasData,
                  ),
                ),
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
            leading:
                widget.data.hasData
                    ? colouredIcon(
                      Icon(
                        CategoryParser.expenseCategoryIcons[categoryIndex %
                            CategoryParser.expenseCategoryIcons.length],
                      ),
                      UiConstant.colorsWithShade100[categoryIndex %
                          CategoryParser.expenseCategoryIcons.length],
                    )
                    : CustomShimmerEffect.imageWidget(
                      shape: BoxShape.circle,
                      radius: 50,
                    ),
            title:
                widget.data.hasData
                    ? Text(widget.data.description)
                    : CustomShimmerEffect.textWidget(width: 125),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                subTextOnCard(
                  "Created On ${convertDateTimeFormat(widget.data.createdOn)}",
                  isLoaded: widget.data.hasData,
                ),
                widget.data.createdOn != widget.data.modifiedOn
                    ? subTextOnCard(
                      "Updated On ${convertDateTimeFormat(widget.data.modifiedOn)}",
                      isLoaded: widget.data.hasData,
                    )
                    : subTextOnCard("", isLoaded: widget.data.hasData),
              ],
            ),
            trailing:
                widget.data.hasData
                    ? Text(
                      formatCurrency(
                        (121 + Random().nextInt(300)) * 1.0,
                        context,
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                    : CustomShimmerEffect.textWidget(width: 50, fontSize: 16),
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
