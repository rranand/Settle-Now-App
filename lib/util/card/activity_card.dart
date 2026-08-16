import 'package:flutter/material.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/internationalization/currency.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class ActivityCard extends StatefulWidget {
  final ActivityModel data;
  const ActivityCard({super.key, required this.data});

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  final ValueNotifier<bool> isExpanded = ValueNotifier(false);
  final TextStyle _textStyle = TextStyle(fontSize: 15, color: Colors.grey);

  String getName(
    BaseUserModel? userData, {
    bool isCapatilizeFirstLetter = false,
  }) {
    if (userData == null || !userData.hasData) {
      return "Unknown";
    }

    String name = userData.name.split(' ').first;

    if (userData.id == UserResolver.instance.getLoggedInUser().id) {
      name = "you";
    }

    return isCapatilizeFirstLetter ? capatilizeFirstLetter(name) : name;
  }

  String getText(BuildContext context) {
    String userFirstName = getName(
      widget.data.user,
      isCapatilizeFirstLetter: true,
    );

    switch (widget.data.entityType) {
      case ActivityType.transactionAdded:
        {
          return "$userFirstName added a transaction of ${formatCurrency(widget.data.newValue!.amount ?? 0, context)}";
        }
      case ActivityType.transactionUpdated:
        {
          return "$userFirstName updated a transaction";
        }
      case ActivityType.transactionDeleted:
        {
          return "$userFirstName deleted a transaction of ${formatCurrency(widget.data.newValue!.amount ?? 0, context)}";
        }
      case ActivityType.settlementAdded:
        {
          double amount = widget.data.newValue!.amount ?? 0;
          String newValueFullName = getName(widget.data.newValue!.user);

          return "$userFirstName settled ${formatCurrency(amount.abs(), context)} ${amount < 0 ? "for" : "with"} $newValueFullName";
        }
      case ActivityType.settlementUpdated:
        {
          double amount = widget.data.newValue!.amount ?? 0;
          String newValueFullName = getName(widget.data.newValue!.user);

          return "$userFirstName updated settlement ${amount < 0 ? "for" : "with"} $newValueFullName";
        }
      case ActivityType.settlementDeleted:
        {
          return "$userFirstName deleted settlement of ${formatCurrency(widget.data.newValue!.amount!.abs(), context)}";
        }
      case ActivityType.roomRenamed:
        {
          return "$userFirstName renamed room";
        }
      case ActivityType.memberAdded:
        {
          final baseUserData = UserResolver.instance.resolve(
            widget.data.entityId,
          );
          return "$userFirstName joined room (approved by ${getName(baseUserData)})";
        }
      case ActivityType.memberRemoved:
        return widget.data.newValue!.description ?? '';
      case ActivityType.roomClosed:
        {
          return "$userFirstName closed room";
        }
      case ActivityType.roomCreated:
        {
          return "$userFirstName created room";
        }
    }
  }

  Widget activityInfoWidget() {
    List<Widget> updateAttributes = [Divider()];

    switch (widget.data.entityType) {
      case ActivityType.transactionUpdated:
        {
          double oldAmount = widget.data.oldValue!.amount!.abs();
          double amount = widget.data.newValue!.amount!.abs();
          String oldDescription = widget.data.oldValue!.description ?? "";
          String description = widget.data.newValue!.description ?? "";

          if (oldAmount != amount) {
            updateAttributes.add(
              Text(
                "Amount: ${formatCurrency(oldAmount, context)} → ${formatCurrency(amount, context)}",
                style: _textStyle,
              ),
            );
          }
          if (oldDescription != description) {
            updateAttributes.add(
              Text(
                "Description: '$oldDescription' → '$description'",
                style: _textStyle,
              ),
            );
          }
        }
      case ActivityType.roomRenamed:
        {
          String oldDescription = widget.data.oldValue!.description ?? "";
          String description = widget.data.newValue!.description ?? "";

          if (oldDescription != description) {
            updateAttributes.add(
              Text(
                "Name: '$oldDescription' → '$description'",
                style: _textStyle,
              ),
            );
          }
        }
      case ActivityType.settlementUpdated:
        {
          double oldAmount = widget.data.oldValue!.amount ?? 0;
          double amount = widget.data.newValue!.amount ?? 0;
          if (oldAmount != amount) {
            updateAttributes.add(
              Text(
                "Amount: ${formatCurrency(oldAmount.abs(), context)} → ${formatCurrency(amount.abs(), context)}",
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
    Widget extendedChangeWidget = activityInfoWidget();
    bool showInfoIcon =
        extendedChangeWidget.runtimeType == Column().runtimeType;

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
                            widget.data.entityType.icon,
                            UiConstant.colors[widget.data.entityType.iconCode],
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
                            subTextOnCard(
                              convertDateTimeFormat(widget.data.createdOn),
                              context,
                              fontSize: 14,
                              isLoaded: widget.data.hasData,
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
                              child: extendedChangeWidget,
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
                visible: showInfoIcon,
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    UiConstant.cardBorderRadius,
                  ),
                  child: ValueListenableBuilder(
                    valueListenable: isExpanded,
                    builder: (context, _, _) {
                      return Icon(
                        isExpanded.value
                            ? Icons.keyboard_arrow_up_outlined
                            : Icons.keyboard_arrow_down_outlined,
                        size: 28,
                        color: Colors.grey,
                      );
                    },
                  ),
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
