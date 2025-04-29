import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/model/room_info_model.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';
import 'package:shimmer/shimmer.dart';

class RoomCard extends StatelessWidget {
  final RoomInfoModel data;
  const RoomCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
      onTap: () {
        context.push("${RouterConstants.roomRouteName}/${data.id}");
      },
      child: Container(
        margin: const EdgeInsets.only(
          left: UiConstant.cardBorderLeftSideStripWidth,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
          color: Colors.transparent,
          border:
              data.hasData
                  ? Border(
                    left: BorderSide(
                      color: getStatusColor(data.status),
                      width: UiConstant.cardBorderLeftSideStripWidth,
                    ),
                  )
                  : null,
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
                      : CustomShimmerEffect.textWidget(width: 250),
                  const SizedBox(height: UiConstant.cardSpaceBetweenSubText),
                  dateOnCard(
                    "Updated On ${convertDateTimeFormat(data.createdOn)}",
                    isLoaded: data.hasData,
                  ),
                  const SizedBox(height: UiConstant.cardSpaceAfterSubText),
                  data.hasData
                      ? overlapUserImageWidget(context, data.users, 4)
                      : CustomShimmerEffect.overlapImageWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
