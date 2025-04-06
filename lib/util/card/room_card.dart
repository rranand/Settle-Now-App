import 'package:flutter/material.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class RoomCard extends StatelessWidget {
  final String status;
  const RoomCard({super.key, required this.status});

  Color getStatusBackgroundColor() {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.green.shade50;
      case 'closed':
        return Colors.red.shade50;
      case 'partially closed':
        return Colors.orange.shade50;
      default:
        return Colors.grey;
    }
  }

  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'closed':
        return Colors.red;
      case 'partially closed':
        return Colors.amber;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: .5 * UiConstant.spaceBetweenSection),
      decoration: BoxDecoration(
        color: getStatusBackgroundColor(),
        borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
        border: Border(
          left: BorderSide(
            color: getStatusColor(),
            width: UiConstant.cardBorderLeftSideStripWidth,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16).add(EdgeInsets.only(bottom: 12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Trip to Bhushan",
              style: const TextStyle(
                fontSize: UiConstant.cardTitleTextSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UiConstant.cardSpaceBetweenSubText),
            dateOnCard("March 15, 2023"),
            const SizedBox(height: UiConstant.cardSpaceAfterSubText),
            overlapUserImageWidget(
              context,
              UiConstant.memberAvatars,
              4,
              totalUsers: UiConstant.memberAvatars.length,
            ),
          ],
        ),
      ),
    );
  }
}
