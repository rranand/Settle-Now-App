import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';

void showSnackbar(
  BuildContext context,
  String txt, {
  Icon? icon,
  ScaffoldMessengerState? scaffoldMessenger,
}) {
  icon ??= Icon(Iconsax.tick_circle5, color: Colors.green);
  final snackBar = SnackBar(
    content: Row(
      children: [
        Padding(padding: const EdgeInsets.only(right: 18.0), child: icon),
        Text(
          txt,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ],
    ),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: Colors.black54, width: 1),
      borderRadius: BorderRadius.circular(24),
    ),
  );

  if (scaffoldMessenger == null) {
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  } else {
    scaffoldMessenger.showSnackBar(snackBar);
  }
}

void showSnackbarWithChildWidget(
  String txt, {
  Widget? child,
  ScaffoldMessengerState? scaffoldMessenger,
  BuildContext? context,
  Duration duration = const Duration(seconds: 1),
}) {
  final snackBar = SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Visibility(
          visible: child != null,
          child: Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: child,
          ),
        ),
        Text(
          txt,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ],
    ),
    duration: duration,
  );

  if (scaffoldMessenger != null) {
    scaffoldMessenger.showSnackBar(snackBar);
  } else if (context != null) {
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

void showSnackbarForUpdate(ScaffoldMessengerState scaffoldMessenger) {
  final snackBar = SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Iconsax.receive_square, color: Colors.green),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "Update Available",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
              onTap: updateHandler,
              child: CustomButton.customTextButton(
                "Update",
                buttonTextColor: Colors.blueGrey.shade200,
                borderColor: Colors.blueGrey.shade200,
              ),
            ),
            IconButton(
              padding: EdgeInsets.all(8),
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () {
                scaffoldMessenger.hideCurrentSnackBar();
              },
            ),
          ],
        ),
      ],
    ),
    duration: Duration(minutes: 5),
  );

  scaffoldMessenger.showSnackBar(snackBar);
}

void showNormalSnackBar(
  BuildContext context,
  String txt, {
  ScaffoldMessengerState? scaffoldMessenger,
}) {
  final snackBar = SnackBar(content: Text(txt));
  if (scaffoldMessenger == null) {
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  } else {
    scaffoldMessenger.showSnackBar(snackBar);
  }
}
