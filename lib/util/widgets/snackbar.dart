import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:settlenow/bloc/auth/auth_bloc.dart';
import 'package:settlenow/constant/ui_constant.dart';
import 'package:settlenow/util/functions/additional_function.dart';
import 'package:settlenow/util/widgets/custom_button.dart';
import 'package:settlenow/util/widgets/widgets.dart';

void showSnackbar(
  BuildContext context,
  String txt, {
  Icon? icon,
  ScaffoldMessengerState? scaffoldMessenger,
}) {
  final snackBar = SnackBar(
    content: Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 18.0),
          child: icon ?? snackbarSuccessIcon(),
        ),
        Text(
          txt,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge!.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      side: BorderSide(
        color: (Theme.of(context).primaryColor).withAlpha(40),
        width: 1,
      ),
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
            Icon(Iconsax.receive_square_copy, color: Colors.green),
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

  if (txt.toLowerCase() == "unauthorized access") {
    context.read<AuthBloc>().add(AuthRevokeSessionRequested());
  }
}
