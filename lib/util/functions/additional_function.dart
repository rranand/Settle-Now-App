import 'dart:math';

import 'package:flutter/material.dart';
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

Color getStatusColor(String status) {
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

bool isDateTimeSame(DateTime d1, DateTime d2) {
  DateTime dC1 = DateTime(d1.year, d1.month, d1.day, d1.hour, d1.minute);
  DateTime dC2 = DateTime(d2.year, d2.month, d2.day, d2.hour, d2.minute);
  return dC1 == dC2;
}

int roundUpToPowerOfTen(int number) {
  int digits = log(number) ~/ ln10;
  int base = pow(10, digits).toInt();

  if (number % base == 0) return number;

  return ((number ~/ base) + 1) * base;
}
