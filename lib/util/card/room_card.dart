import 'package:flutter/material.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';

class RoomCard extends StatelessWidget {
  final String status;
  RoomCard({super.key, required this.status});

  final List<String> memberAvatars = [
    "https://picsum.photos/id/237/200/300",
    "https://picsum.photos/id/238/200/300",
    "https://picsum.photos/id/239/200/300",
    "https://picsum.photos/id/240/200/300",
    "https://picsum.photos/id/241/200/300",
    "https://picsum.photos/id/242/200/300",
    "https://picsum.photos/id/243/200/300",
    "https://picsum.photos/id/244/200/300",
  ];

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
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: getStatusColor(), width: 4.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16).add(EdgeInsets.only(bottom: 12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Trip to Bhushan",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('March 15, 2023', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            overlapUserImageWidget(
              context,
              memberAvatars,
              4,
              totalUsers: memberAvatars.length,
            ),
          ],
        ),
      ),
    );
  }
}
