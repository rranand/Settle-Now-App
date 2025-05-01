import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/model/transaction_model.dart';
import 'package:settlenow_v2/model/user_amount_model.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class QuickSplitCard extends StatefulWidget {
  final TransactionModel data;
  const QuickSplitCard({super.key, required this.data});

  @override
  State<QuickSplitCard> createState() => _QuickSplitCardState();
}

class _QuickSplitCardState extends State<QuickSplitCard> {
  final ValueNotifier<bool> isExpanded = ValueNotifier(false);

  List<String> createTags() {
    List<String> tags = [widget.data.category];
    if (widget.data.createdOn != widget.data.modifiedOn) {
      tags.add("Edited");
    }
    return tags;
  }

  Widget transactionInfoWidget(bool value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: !value,
          child: const SizedBox(height: UiConstant.cardSpaceAfterSubText),
        ),
        widget.data.hasData
            ? Visibility(
              visible: !value,
              child: overlapUserImageWidget(
                context,
                [widget.data.createdBy, ...widget.data.users],
                4,
                imageRadius: 30,
                nextImageOffset: 24,
              ),
            )
            : CustomShimmerEffect.overlapImageWidget(),
        Visibility(
          visible: !value,
          child: const SizedBox(height: UiConstant.cardSpaceAfterSubText),
        ),
        subTextOnCard(
          "Created By ${widget.data.createdBy.name}",
          isLoaded: widget.data.hasData,
        ),
        subTextOnCard(
          "Created ${convertDateTimeFormat(widget.data.createdOn)}",
          isLoaded: widget.data.hasData,
        ),
        Visibility(
          visible: widget.data.createdOn != widget.data.modifiedOn,
          child: subTextOnCard(
            "Updated ${convertDateTimeFormat(widget.data.modifiedOn)}",
            isLoaded: widget.data.hasData,
          ),
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
          itemCount: widget.data.users.length + 1,
          itemBuilder: (BuildContext context, int index) {
            UserAmountModel user = UserAmountModel.empty();
            if (index == 0) {
              user = widget.data.createdBy;
            } else {
              user = widget.data.users[index - 1];
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    overlapUserImageWidget(context, [user], 1),
                    SizedBox(width: 8),
                    Text(user.name),
                  ],
                ),
                Text(
                  formatCurrency(user.amount, context),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: user.amount < 0 ? Colors.red : Colors.green,
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
    List<String> tags = createTags();
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
                visible: widget.data.hasData,
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
                        widget.data.hasData
                            ? Text(
                              widget.data.description,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                            : CustomShimmerEffect.textWidget(width: 250),
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
              Builder(
                builder: (context) {
                  if (widget.data.hasData) {
                    UserAmountModel userData = widget.data.users.first;
                    return Text(
                      formatCurrency(userData.amount, context),
                      style: TextStyle(
                        color: userData.amount < 0 ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    );
                  } else {
                    return CustomShimmerEffect.textWidget(
                      width: 50,
                      fontSize: 16,
                    );
                  }
                },
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
