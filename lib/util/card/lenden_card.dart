import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/model/lenden_dashboard_model.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';
import 'package:shimmer/shimmer.dart';

class LendenCard extends StatelessWidget {
  final LendenDashboardModel data;
  const LendenCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
      onTap: () {
        if (data.hasData) {
          context.push("${RouterConstants.lendenRouteName}/${data.id}");
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
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
                  shimmerDirection: ShimmerDirection.ttb,
                ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                    "Updated On ${convertDateTimeFormat(data.modifiedOn)}",
                    isLoaded: data.hasData,
                  ),
                  const SizedBox(height: UiConstant.cardSpaceBetweenSubText),
                  dateOnCard(
                    "Created By ${data.createdBy.name.split(' ').first}",
                    isLoaded: data.hasData,
                  ),
                  const SizedBox(height: UiConstant.cardSpaceAfterSubText),
                  data.hasData
                      ? Text(
                        "${data.amount < 0 ? "-" : "+"} ${formatCurrency(data.amount.abs(), context)}",
                        style: TextStyle(
                          color: data.amount < 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )
                      : CustomShimmerEffect.textWidget(width: 100),
                  const SizedBox(height: UiConstant.cardSpaceAfterSubText),
                  data.hasData
                      ? overlapUserImageWidget(
                        context,
                        data.users,
                        4,
                        imageRadius: 30,
                        nextImageOffset: 24,
                      )
                      : CustomShimmerEffect.overlapImageWidget(noOfImages: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
