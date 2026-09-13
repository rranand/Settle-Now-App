import 'package:flutter/material.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ActivityNotificationCard extends StatefulWidget {
  final ActivityNotificationModel data;
  const ActivityNotificationCard({super.key, required this.data});

  @override
  State<ActivityNotificationCard> createState() =>
      _ActivityNotificationCardState();
}

class _ActivityNotificationCardState extends State<ActivityNotificationCard> {
  final ValueNotifier<bool> isExpanded = ValueNotifier(false);
  final TextStyle _textStyle = TextStyle(fontSize: 15, color: Colors.grey);

  Widget activityInfoWidget() {
    List<Widget> updateAttributes = [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Divider(),
      ),
    ];

    switch (widget.data.type) {
      case NotificationType.transactionAdded:
      case NotificationType.transactionUpdated:
      case NotificationType.transactionDeleted:
        {
          String amount = widget.data.data['amount'] ?? "";
          String description = widget.data.data['description'] ?? "";

          if (amount.isNotEmpty) {
            updateAttributes.add(Text("Amount: $amount", style: _textStyle));
          }
          if (description.isNotEmpty) {
            updateAttributes.add(
              Text("Description: $description", style: _textStyle),
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
    Widget extendedChangeWidget = activityInfoWidget();
    bool showInfoIcon =
        extendedChangeWidget.runtimeType == Column().runtimeType;

    return VisibilityDetector(
      key: Key(widget.data.id),
      onVisibilityChanged: (visibilityInfo) {
        final visiblePercentage = visibilityInfo.visibleFraction;
        if (visiblePercentage >= 0.7 && widget.data.readOn == null) {
          NotificationReadTracker().markAsRead(widget.data.id, context);
        }
      },
      child: Card(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: UiConstant.cardPadding,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
            boxShadow: getContainerBoxShadow(context),
          ),
          child: ListTile(
            titleAlignment: ListTileTitleAlignment.top,
            contentPadding: EdgeInsets.zero,
            leading:
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
            title:
                widget.data.hasData
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.data.body,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Visibility(
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
                      ],
                    )
                    : CustomShimmerEffect.textWidget(context, width: 80),
            subtitle:
                widget.data.hasData
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            subTextOnCard(
                              widget.data.title,
                              context,
                              fontSize: 14,
                              isLoaded: true,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '•',
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 6),
                            subTextOnCard(
                              convertToMoment(widget.data.createdOn),
                              context,
                              fontSize: 14,
                              isLoaded: true,
                            ),
                          ],
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
                    )
                    : Align(
                      alignment: Alignment.centerLeft,
                      child: CustomShimmerEffect.textWidget(
                        context,
                        fontSize: 10,
                        width: 80,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
