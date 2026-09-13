import 'package:flutter/material.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ActivityNotificationCard extends StatelessWidget {
  final ActivityNotificationModel data;
  const ActivityNotificationCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(data.id),
      onVisibilityChanged: (visibilityInfo) {
        final visiblePercentage = visibilityInfo.visibleFraction;
        if (visiblePercentage >= 0.7 && data.readOn == null) {
          NotificationReadTracker().markAsRead(data.id, context);
        }
      },
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(UiConstant.cardPadding),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
            boxShadow: getContainerBoxShadow(context),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: null,
                title: Text(data.id),
                subtitle:
                    data.hasData
                        ? Text(
                          data.type.label,
                          style: TextStyle(color: Colors.grey[600]),
                        )
                        : CustomShimmerEffect.textWidget(
                          context,
                          fontSize: 10,
                          width: 80,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
