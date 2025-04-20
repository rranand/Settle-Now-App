import 'package:flutter/widgets.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';

List<double> calculateCrossAspectRatio(
  double screenWidth,
  EdgeInsets mainScreenPadding, {
  double cardHeight = UiConstant.cardFixedHeight,
  double cardWidth = -1,
}) {
  final isWide = screenWidth >= UiConstant.maxWidth;

  if (cardWidth > 0) {
    bool isWide = screenWidth >= UiConstant.maxWidth;
    final boxWidth =
        isWide
            ? cardWidth
            : (screenWidth / 2) -
                UiConstant.spaceBetweenCard * .5 -
                mainScreenPadding.left;

    return [boxWidth, boxWidth / cardHeight];
  } else {
    final boxWidth =
        isWide
            ? (screenWidth / 2) -
                UiConstant.spaceBetweenCard -
                mainScreenPadding.left
            : screenWidth;

    return [boxWidth, boxWidth / cardHeight];
  }
}
