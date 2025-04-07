import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';

Widget dateOnCard(String date) {
  return Text(date, style: TextStyle(color: Colors.grey));
}

Widget subTextOnCard(
  String text, {
  Color? textColor = Colors.grey,
  FontWeight? fontWeight = FontWeight.w400,
}) {
  return Text(
    text,
    style: TextStyle(color: textColor, fontSize: 12, fontWeight: fontWeight),
  );
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
      child: const Icon(Iconsax.arrow_left_2),
      onTap: () => context.pop(),
    ),
  );
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

Widget colouredIcon(Icon icon, Color color, {double radius = 50}) {
  return Container(
    width: radius,
    height: radius,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    child: icon,
  );
}

Widget tagOnCard(
  String text, {
  Color textColor = Colors.deepPurple,
  Color? backgroundColor,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
    decoration: BoxDecoration(
      color: backgroundColor ?? Colors.deepPurple.shade50,
      borderRadius: BorderRadius.circular(100),
    ),
    child: subTextOnCard(
      text,
      textColor: textColor,
      fontWeight: FontWeight.bold,
    ),
  );
}
