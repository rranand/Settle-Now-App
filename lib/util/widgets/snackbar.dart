import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

void showSnackbar(BuildContext context, String txt, {Icon? icon}) {
  icon ??= Icon(Iconsax.tick_circle5, color: Colors.green);
  final snackBar = SnackBar(
    content: Row(
      children: [
        icon,
        SizedBox(width: 18),
        Text(
          txt,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ],
    ),
    padding: const EdgeInsets.all(10),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: Colors.black54, width: 1),
      borderRadius: BorderRadius.circular(24),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showNormalSnackBar(BuildContext context, String txt) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(txt)));
}
