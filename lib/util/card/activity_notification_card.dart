import 'package:flutter/material.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class ActivityNotificationCard extends StatelessWidget {
  final ActivityNotificationModel data;
  const ActivityNotificationCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
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
              title: Text(data.body),
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
    );
  }
}
