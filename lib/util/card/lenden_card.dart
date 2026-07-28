import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/internationalization/currency.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/router/router_constant.dart';
import 'package:settlenow/util/util_core.dart';
import 'package:shimmer/shimmer.dart';

class LendenCard extends StatelessWidget {
  final LendenDashboardModel data;
  const LendenCard({super.key, required this.data});

  Widget _totalAmountWidget(BuildContext context) {
    Pair<double, double> amount = data.getAmount();
    double netAmount = amount.first - amount.second;

    return Text(
      "${netAmount < 0 ? "-" : "+"} ${formatCurrency(netAmount.abs(), context)}",
      style: TextStyle(
        color: netAmount < 0 ? Colors.red : Colors.green,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

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
                      color: getStatusColor(data.status.label),
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
                      ? _totalAmountWidget(context)
                      : CustomShimmerEffect.textWidget(context, width: 100),
                  const SizedBox(height: UiConstant.cardSpaceAfterSubText),
                  data.hasData
                      ? overlapUserImageWidget(
                        context,
                        data.users,
                        4,
                        imageRadius: 30,
                        nextImageOffset: 24,
                      )
                      : CustomShimmerEffect.overlapImageWidget(
                        context,
                        noOfImages: 2,
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
