import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
  BuildContext context,
  String txt, {
  Widget? child,
  ScaffoldMessengerState? scaffoldMessenger,
  Duration duration = const Duration(seconds: 1),
}) {
  final snackBar = SnackBar(
    content: Row(
      children: [
        Visibility(
          visible: child != null,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: child,
          ),
        ),
        Text(
          txt,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ],
    ),
    duration: duration,
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
