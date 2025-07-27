import 'package:flutter/material.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:shimmer/shimmer.dart';

class CustomShimmerEffect {
  static Widget placeHolderShimmerEffect(
    Widget child, {
    ShimmerDirection shimmerDirection = ShimmerDirection.ltr,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      direction: shimmerDirection,
      child: child,
    );
  }

  static Widget loadingShimmerEffect(
    Widget child, {
    Color? baseColor,
    Color? highlightColor,
  }) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Color.fromARGB(255, 2, 148, 181),
      highlightColor: highlightColor ?? Color(0xFFf64f59),
      child: child,
    );
  }

  static Widget shimmerCircularProgressIndicator({
    double radius = 16,
    double strokeWidth = 4,
    Color? indicatorColor,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return CustomShimmerEffect.loadingShimmerEffect(
      baseColor: baseColor,
      highlightColor: highlightColor,
      SizedBox(
        height: radius,
        width: radius,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            color: indicatorColor,
          ),
        ),
      ),
    );
  }

  static Widget shimmerCircularProgressIndicatorForSnackbar() {
    return shimmerCircularProgressIndicator(
      baseColor: Color(0xFF86A8E7),
      highlightColor: Colors.green,
      radius: 16,
      strokeWidth: 2,
      indicatorColor: Colors.green,
    );
  }

  static Widget imageWidget({
    BoxShape shape = BoxShape.rectangle,
    double radius = 12,
  }) {
    return placeHolderShimmerEffect(
      Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          shape: shape,
          borderRadius:
              shape == BoxShape.rectangle
                  ? BorderRadius.circular(radius)
                  : null,
          color: Colors.white,
        ),
      ),
    );
  }

  static Widget overlapImageWidget({
    int noOfImages = 4,
    double nextImageOffset = 22,
    double imageRadius = 30,
  }) {
    return SizedBox(
      width:
          noOfImages * imageRadius +
          (noOfImages - 1) * (nextImageOffset - imageRadius),
      height: imageRadius,
      child: Stack(
        children: List.generate(
          noOfImages,
          (i) => Positioned(
            left: i * nextImageOffset,
            child: imageWidget(shape: BoxShape.circle, radius: imageRadius),
          ),
        ),
      ),
    );
  }

  static Widget textWidget({
    double fontSize = 14,
    int maxLines = 1,
    double? width,
    bool isBlock = false,
    double blockRadius = 12,
  }) {
    double seperatorHeight = 3;

    if (isBlock) {
      return SizedBox(
        width: width,
        height: fontSize * 1.2 * maxLines + (maxLines - 1) * seperatorHeight,
        child: imageWidget(radius: blockRadius),
      );
    }

    return placeHolderShimmerEffect(
      SizedBox(
        width: width,
        height: fontSize * 1.2 * maxLines + (maxLines - 1) * seperatorHeight,
        child: ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: maxLines,
          separatorBuilder:
              (context, index) => SizedBox(height: seperatorHeight),
          itemBuilder:
              (context, ind) => Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
                height: fontSize * 1.2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(fontSize),
                  color: Colors.white,
                ),
              ),
        ),
      ),
    );
  }

  static Widget searchCardEvent(
    double horizontalPadding,
    double verticalPadding,
    double imageHeight,
    double headerFontSize,
    double eventDetailFontSize,
    double eventCapacityFontSize,
    double eventCategoryFontSize,
    double spaceBetweenEventDetail,
  ) {
    return placeHolderShimmerEffect(
      ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        itemCount: 10,
        shrinkWrap: true,
        padding: EdgeInsets.all(0),
        separatorBuilder: (context, index) => Divider(height: 3),
        itemBuilder:
            (context, eventItemIndex) => Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: imageHeight,
                    child: imageWidget(),
                  ),
                  SizedBox(height: UiConstant.spaceBetweenSection),
                  SizedBox(
                    width: 200,
                    child: textWidget(fontSize: headerFontSize),
                  ),
                  SizedBox(height: spaceBetweenEventDetail),
                  SizedBox(
                    width: 250,
                    child: textWidget(fontSize: eventDetailFontSize),
                  ),
                  SizedBox(height: spaceBetweenEventDetail),
                  SizedBox(
                    height: 22,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder:
                          (context, index) => SizedBox(
                            width: index == 0 ? 80 : 50,
                            child: textWidget(fontSize: eventCategoryFontSize),
                          ),
                      separatorBuilder: (context, index) => SizedBox(width: 8),
                      itemCount: 4,
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
