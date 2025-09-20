import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:settlenow/constant/ui_constant.dart';
import 'package:settlenow/internationalization/currency.dart';
import 'package:settlenow/model/activity_model.dart';
import 'package:settlenow/util/enum/activity_type.dart';
import 'package:settlenow/util/functions/text_function.dart';
import 'package:settlenow/util/widgets/shimmer_effect.dart';
import 'package:settlenow/util/widgets/widgets.dart';

class ActivityCard extends StatefulWidget {
  final ActivityModel data;
  final Map<String, String> userMapping;
  const ActivityCard({
    super.key,
    required this.data,
    required this.userMapping,
  });

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  final ValueNotifier<bool> isExpanded = ValueNotifier(false);
  final TextStyle _textStyle = TextStyle(fontSize: 16);

  String getText(BuildContext context) {
    switch (widget.data.type) {
      case ActivityType.transactionAdded:
        {
          return "${widget.userMapping[widget.data.user] ?? "Unknown"} added a transaction of ${formatCurrency(widget.data.details!.newValue!.amount ?? 0, context)}";
        }
      case ActivityType.transactionUpdated:
        {
          return "${widget.userMapping[widget.data.user] ?? "Unknown"} updated a transaction";
        }
      case ActivityType.transactionDeleted:
        {
          return "${widget.userMapping[widget.data.user] ?? "Unknown"} deleted a transaction of ${formatCurrency(widget.data.details!.newValue!.amount ?? 0, context)}";
        }
      case ActivityType.settlementAdded:
        {
          double amount = widget.data.details!.newValue!.amount ?? 0;
          if (amount < 0) {
            return "${widget.userMapping[widget.data.user] ?? "Unknown"} settled ${formatCurrency(amount * -1, context)} for ${widget.userMapping[widget.data.details!.newValue!.user] ?? "Unknown"}";
          } else {
            return "${widget.userMapping[widget.data.user] ?? "Unknown"} settled ${formatCurrency(amount, context)} with ${widget.userMapping[widget.data.details!.newValue!.user] ?? "Unknown"}";
          }
        }
      case ActivityType.settlementUpdated:
        {
          double amount = widget.data.details!.newValue!.amount ?? 0;
          if (amount < 0) {
            return "${widget.userMapping[widget.data.user] ?? "Unknown"} updated settlement for ${widget.userMapping[widget.data.details!.newValue!.user] ?? "Unknown"}";
          } else {
            return "${widget.userMapping[widget.data.user] ?? "Unknown"} updated settlement with ${widget.userMapping[widget.data.details!.newValue!.user] ?? "Unknown"}";
          }
        }
      case ActivityType.settlementDeleted:
        {
          return "${widget.userMapping[widget.data.user] ?? "Unknown"} deleted settlement of ${formatCurrency(widget.data.details!.newValue!.amount ?? 0, context)}";
        }
      case ActivityType.roomRenamed:
        {
          return "${widget.userMapping[widget.data.user] ?? "Unknown"} renamed room";
        }
      case ActivityType.memberAdded:
        {
          return "${widget.userMapping[widget.data.entityId] ?? "Unknown"} joined room (approved by ${widget.userMapping[widget.data.user] ?? "Unknown"})";
        }
      case ActivityType.memberRemoved:
        return widget.data.details!.newValue!.description ?? '';
      case ActivityType.roomClosed:
        {
          return "${widget.userMapping[widget.data.user] ?? "Unknown"} closed room";
        }
      case ActivityType.roomCreated:
        {
          return "${widget.userMapping[widget.data.user] ?? "Unknown"} created room";
        }
    }
  }

  bool showInfoIcon() {
    switch (widget.data.type) {
      case ActivityType.transactionUpdated:
      case ActivityType.settlementUpdated:
      case ActivityType.roomRenamed:
        return true;
      default:
        return false;
    }
  }

  Widget activityInfoWidget() {
    List<Widget> updateAttributes = [Divider()];

    switch (widget.data.type) {
      case ActivityType.transactionUpdated:
        {
          double oldAmount = widget.data.details!.oldValue!.amount ?? 0;
          double amount = widget.data.details!.newValue!.amount ?? 0;
          String oldDescription =
              widget.data.details!.oldValue!.description ?? "";
          String description = widget.data.details!.newValue!.description ?? "";

          if (oldAmount != amount) {
            updateAttributes.add(
              Text(
                "Amount changed from ${formatCurrency(oldAmount, context)} to ${formatCurrency(amount, context)}",
                style: _textStyle,
              ),
            );
          }
          if (oldDescription != description) {
            updateAttributes.add(
              Text(
                "Description changed from '$oldDescription' to '$description'",
                style: _textStyle,
              ),
            );
          }
        }
      case ActivityType.roomRenamed:
        {
          String oldDescription =
              widget.data.details!.oldValue!.description ?? "";
          String description = widget.data.details!.newValue!.description ?? "";

          if (oldDescription != description) {
            updateAttributes.add(
              Text(
                "Name changed from '$oldDescription' to '$description'",
                style: _textStyle,
              ),
            );
          }
        }
      case ActivityType.settlementUpdated:
        {
          double oldAmount = widget.data.details!.oldValue!.amount ?? 0;
          double amount = widget.data.details!.newValue!.amount ?? 0;
          if (oldAmount != amount) {
            updateAttributes.add(
              Text(
                "Amount changed from ${formatCurrency(oldAmount.abs(), context)} to ${formatCurrency(amount.abs(), context)}",
                style: _textStyle,
              ),
            );
          }
        }
      default:
        {
          updateAttributes = [];
        }
    }

    if (updateAttributes.length <= 1) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: updateAttributes,
    );
  }

  @override
  Widget build(BuildContext context) {
    String activityText = getText(context);
    if (activityText.isEmpty) {
      return SizedBox.shrink();
    }
    return Column(
      children: [
        Stack(
          children: [
            Card(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(
                    UiConstant.cardBorderRadius,
                  ),
                  boxShadow: getContainerBoxShadow(context),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.data.hasData
                          ? colouredIcon(
                            widget.data.type.icon,
                            UiConstant.colors[widget.data.type.iconCode],
                          )
                          : CustomShimmerEffect.imageWidget(
                            context,
                            shape: BoxShape.circle,
                            radius: 50,
                          ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widget.data.hasData
                                ? Text(
                                  activityText,
                                  style: TextStyle(fontSize: 17),
                                )
                                : CustomShimmerEffect.textWidget(
                                  context,
                                  width: 80,
                                ),
                            widget.data.hasData
                                ? subTextOnCard(
                                  convertToMoment(widget.data.createdOn),
                                  context,
                                  fontSize: 15,
                                  isLoaded: widget.data.hasData,
                                )
                                : CustomShimmerEffect.textWidget(
                                  context,
                                  fontSize: 10,
                                  width: 80,
                                ),
                            ValueListenableBuilder(
                              valueListenable: isExpanded,
                              builder: (context, _, child) {
                                if (isExpanded.value) {
                                  return child!;
                                } else {
                                  return SizedBox.shrink();
                                }
                              },
                              child: activityInfoWidget(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Visibility(
                visible: showInfoIcon(),
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    UiConstant.cardBorderRadius,
                  ),
                  child: Icon(Iconsax.info_circle_copy, color: Colors.grey),
                  onTap: () {
                    isExpanded.value = !isExpanded.value;
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
