import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';

Widget dateOnCard(String date, {bool isLoading = true}) {
  return isLoading
      ? Text(date, style: TextStyle(color: Colors.grey))
      : CustomShimmerEffect.textWidget(width: 200);
}

Widget subTextOnCard(
  String text, {
  Color? textColor = Colors.grey,
  FontWeight? fontWeight = FontWeight.w400,
  double? fontSize = 12,
  bool isLoading = true,
}) {
  return isLoading
      ? Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      )
      : CustomShimmerEffect.textWidget(fontSize: 12, width: 120);
}

Widget appBarBackButton(BuildContext context) {
  EdgeInsets viewPadding = MediaQuery.of(context).viewPadding;
  double notchPadding = max(max(viewPadding.left, viewPadding.right), 0);
  double width = max(
    context.watch<ScreenSizeProvider>().getPadding.left - notchPadding,
    0,
  );

  return Padding(
    padding: EdgeInsets.only(left: width),
    child: InkWell(
      borderRadius: BorderRadius.circular(100),
      child: const Icon(Iconsax.arrow_left_2),
      onTap: () => context.pop(),
    ),
  );
}

Widget appBarLeadingButton(BuildContext context, Widget child) {
  EdgeInsets viewPadding = MediaQuery.of(context).viewPadding;
  double notchPadding = max(max(viewPadding.left, viewPadding.right), 0);
  double width = max(
    context.watch<ScreenSizeProvider>().getPadding.left - notchPadding,
    0,
  );

  return Padding(padding: EdgeInsets.only(left: width), child: child);
}

List<Widget>? appBarActionButton(BuildContext context, List<Widget> widgets) {
  if (widgets.isEmpty) {
    return null;
  } else {
    EdgeInsets viewPadding = MediaQuery.of(context).viewPadding;
    double notchPadding = max(max(viewPadding.left, viewPadding.right), 0);
    double width = max(
      context.watch<ScreenSizeProvider>().getPadding.right - notchPadding,
      0,
    );
    widgets.add(SizedBox(width: width));
    return widgets;
  }
}

Widget colouredIcon(Widget child, Color color, {double radius = 50}) {
  return Container(
    width: radius,
    height: radius,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    child: Center(child: child),
  );
}

Widget tagOnCard(
  String text, {
  Color textColor = Colors.deepPurple,
  Color? backgroundColor,
  bool isFirst = false,
  bool isLoading = false,
}) {
  return isLoading
      ? Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        margin: EdgeInsets.only(left: isFirst ? 0 : 4),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(100),
        ),
        child: subTextOnCard(
          capatilizeFirstLetter(text),
          textColor: textColor,
          fontWeight: FontWeight.bold,
        ),
      )
      : CustomShimmerEffect.textWidget(width: 100);
}

Future<dynamic> loadingWidget(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator.adaptive(),
            SizedBox(height: 4),
            Text(
              "Loading...",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    },
  );
}
