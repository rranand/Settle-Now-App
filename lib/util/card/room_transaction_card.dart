import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class RoomTransactionCard extends StatefulWidget {
  final String roomID;
  final TransactionModel data;
  final UserModel loggedInUser;

  const RoomTransactionCard({
    super.key,
    required this.roomID,
    required this.data,
    required this.loggedInUser,
  });

  @override
  State<RoomTransactionCard> createState() => _RoomTransactionCardState();
}

class _RoomTransactionCardState extends State<RoomTransactionCard> {
  final ValueNotifier<bool> isExpanded = ValueNotifier(false);

  List<String> createTags() {
    List<String> tags = [widget.data.category];
    if (widget.data.createdBy.amount == widget.data.amount) {
      tags.add("Self");
    } else if (widget.data.users.isNotEmpty) {
      tags.add("Partial");
    }
    if (widget.data.createdOn != widget.data.modifiedOn) {
      tags.add("Edited");
    }
    return tags;
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
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      overlapUserImageWidget(context, [user], 1),
                      SizedBox(width: 8),
                      Text(
                        "${user.name}${widget.loggedInUser.id == user.id ? " (You)" : ""}",
                      ),
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
    bool isManualSplit = false;
    if (widget.data.users.isNotEmpty) {
      isManualSplit = true;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
      onTap: () {
        if (widget.loggedInUser.id == widget.data.createdBy.id) {
          context.push(
            "${RouterConstants.roomRouteName}/${widget.roomID}${RouterConstants.roomEditExpenseRouteName}",
            extra: widget.data,
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(UiConstant.cardPadding),
        margin: EdgeInsets.symmetric(vertical: 2),
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
                  visible: isManualSplit,
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
              contentPadding: EdgeInsets.zero,
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
                    "Created By ${widget.loggedInUser.id == widget.data.createdBy.id ? "You" : widget.data.createdBy.name}",
                    isLoaded: widget.data.hasData,
                  ),
                  subTextOnCard(
                    "Created ${convertDateTimeFormat(widget.data.createdOn)}",
                    isLoaded: widget.data.hasData,
                  ),
                  isDateTimeSame(widget.data.createdOn, widget.data.modifiedOn)
                      ? subTextOnCard(
                        "Updated ${convertDateTimeFormat(widget.data.modifiedOn)}",
                        isLoaded: widget.data.hasData,
                      )
                      : subTextOnCard("", isLoaded: widget.data.hasData),
                ],
              ),
              trailing:
                  widget.data.hasData
                      ? Text(
                        formatCurrency(widget.data.amount, context),
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
      ),
    );
  }
}
