import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow/constant/ui_constant.dart';
import 'package:settlenow/model/room_info_model.dart';
import 'package:settlenow/model/user_model.dart';
import 'package:settlenow/router/router_constant.dart';
import 'package:settlenow/util/functions/additional_function.dart';
import 'package:settlenow/util/functions/text_function.dart';
import 'package:settlenow/util/widgets/shimmer_effect.dart';
import 'package:settlenow/util/widgets/stacked_image.dart';
import 'package:settlenow/util/widgets/widgets.dart';
import 'package:shimmer/shimmer.dart';

class RoomCard extends StatelessWidget {
  final RoomInfoModel data;
  const RoomCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    List<UserModel> users = data.users.map((obj) => obj.user).toList();
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
                    "Created By ${data.createdBy.name.split(' ').first}",
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
