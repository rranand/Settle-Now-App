import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/router/router_constant.dart';
import 'package:settlenow/util/util_core.dart';
import 'package:shimmer/shimmer.dart';

class RoomCard extends StatelessWidget {
  final RoomInfoModel data;
  const RoomCard({super.key, required this.data});

  String getName(String createdBy) {
    return data.users
        .firstWhere(
          (element) => element.id == createdBy,
          orElse: () => RoomUserModel.empty(),
        )
        .name;
  }

  @override
  Widget build(BuildContext context) {
    final users = data.users;

    return InkWell(
      borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
      onTap: () {
        if (data.hasData) {
          context.push("${RouterConstants.roomRouteName}/${data.id}");
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
          color: Theme.of(context).cardTheme.color,
          border:
              data.hasData
                  ? Border(
                    left: BorderSide(
                      color: getStatusColor(data.status),
                      width: UiConstant.cardBorderLeftSideStripWidth,
                    ),
                  )
                  : null,
          boxShadow: getContainerBoxShadow(context),
        ),
        child: Stack(
          children: [
            data.hasData
                ? SizedBox.shrink()
                : CustomShimmerEffect.placeHolderShimmerEffect(
                  Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: UiConstant.cardBorderLeftSideStripWidth,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              UiConstant.cardBorderRadius,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  context,
                  shimmerDirection: ShimmerDirection.ttb,
                ),
            Padding(
              padding: const EdgeInsets.all(
                16,
              ).add(EdgeInsets.only(bottom: 12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  data.hasData
                      ? Text(
                        data.roomName,
                        style: const TextStyle(
                          fontSize: UiConstant.cardTitleTextSize,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : CustomShimmerEffect.textWidget(context, width: 250),

                  const SizedBox(height: UiConstant.cardSpaceBetweenSubText),
                  dateOnCard(
                    "Updated On ${convertDateTimeFormat(data.modifiedOn)}",
                    context,
                    isLoaded: data.hasData,
                  ),
                  const SizedBox(height: UiConstant.cardSpaceBetweenSubText),
                  dateOnCard(
                    "Created By ${getName(data.createdBy).split(' ').first}",
                    context,
                    isLoaded: data.hasData,
                  ),
                  const SizedBox(height: UiConstant.cardSpaceAfterSubText),
                  data.hasData
                      ? overlapUserImageWidget(context, users, 4)
                      : CustomShimmerEffect.overlapImageWidget(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
