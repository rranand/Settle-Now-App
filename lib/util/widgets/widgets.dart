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
  return Padding(
    padding: EdgeInsets.only(
      left: context.watch<ScreenSizeProvider>().getPadding.left,
    ),
    child: IconButton(
      color: Colors.black,
      icon: const Icon(Iconsax.arrow_left_2),
      onPressed: () => context.pop(),
    ),
  );
}

Widget colouredIcon(Icon icon, Color color, {double radius = 50}) {
  return Container(
    width: radius,
    height: radius,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    child: icon,
  );
}
