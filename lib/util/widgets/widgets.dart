import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/enum/enums.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/functions/validator.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';

Widget dateOnCard(String date, BuildContext context, {bool isLoaded = true}) {
  return isLoaded
      ? Text(date, style: TextStyle(color: Colors.grey))
      : CustomShimmerEffect.textWidget(context, width: 200);
}

Widget subTextOnCard(
  String text,
  BuildContext context, {
  Color? textColor = Colors.grey,
  FontWeight? fontWeight = FontWeight.w400,
  double? fontSize = 12,
  bool isLoaded = true,
}) {
  return isLoaded
      ? Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      )
      : Padding(
        padding: EdgeInsets.only(top: 6),
        child: CustomShimmerEffect.textWidget(
          context,
          fontSize: 12,
          width: 120,
        ),
      );
}

Widget appBarBackButton(BuildContext context) {
  double width = 0;
  if (!kIsWeb) {
    EdgeInsets viewPadding = MediaQuery.of(context).viewPadding;
    double notchPadding =
        kIsWeb ? 0 : max(max(viewPadding.left, viewPadding.right), 0);

    width = max(
      context.watch<ScreenSizeProvider>().getPadding.left - notchPadding,
      0,
    );
  }

  return Padding(
    padding: EdgeInsets.only(left: width),
    child: IconButton(
      icon: const Icon(Iconsax.arrow_left_2_copy),
      onPressed: () {
        context.pop();
      },
    ),
  );
}

Widget appBarLeadingButton(BuildContext context, Widget child) {
  double width = 0;
  if (!kIsWeb) {
    EdgeInsets viewPadding = MediaQuery.of(context).viewPadding;
    double notchPadding = max(max(viewPadding.left, viewPadding.right), 0);
    width = max(
      context.watch<ScreenSizeProvider>().getPadding.left - notchPadding,
      0,
    );
  }

  return Padding(padding: EdgeInsets.only(left: width), child: child);
}

List<Widget>? appBarActionButton(BuildContext context, List<Widget> widgets) {
  if (widgets.isEmpty) {
    return null;
  } else if (kIsWeb) {
    return widgets;
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

Widget colouredIcon(
  IconData child,
  Color color, {
  double radius = 50,
  double? iconSize,
}) {
  return Container(
    width: radius,
    height: radius,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    child: Center(child: Icon(child, color: Colors.black87, size: iconSize)),
  );
}

Widget colouredWidget(Widget child, Color color, {double radius = 50}) {
  return Container(
    width: radius,
    height: radius,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    child: Center(child: child),
  );
}

Widget tagOnCard(
  String text,
  BuildContext context, {
  Color textColor = Colors.deepPurple,
  Color? backgroundColor,
  bool isFirst = false,
  bool isLoaded = true,
}) {
  return isLoaded
      ? Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        margin: EdgeInsets.only(left: isFirst ? 0 : 4),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(100),
        ),
        child: subTextOnCard(
          capatilizeFirstLetter(text),
          context,
          textColor: textColor,
          fontWeight: FontWeight.bold,
        ),
      )
      : CustomShimmerEffect.textWidget(context, width: 100);
}

Widget snackbarSuccessIcon() {
  return Icon(Iconsax.tick_circle_copy, color: Colors.green);
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

Widget noRecordFoundWidget(String txt, BuildContext context) {
  return ListView(
    shrinkWrap: true,
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      SizedBox(
        height:
            MediaQuery.of(context).size.height -
            kToolbarHeight -
            kBottomNavigationBarHeight -
            2 * UiConstant.spaceAtBottom,
        child: Center(
          child: Text(txt, style: TextStyle(fontSize: 20, color: Colors.grey)),
        ),
      ),
    ],
  );
}

Widget dot() {
  return Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
  );
}

Future<bool> deleteExpenseDialog(BuildContext context) async {
  List<String>? res = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Delete Expense"),
        content: Text("Are You Sure?", style: TextStyle(fontSize: 18)),
        actions: [
          CustomButton.customTextButton(
            "No",
            onPressed: () {
              context.pop(["No"]);
            },
            buttonTextColor: Theme.of(context).textTheme.bodyLarge!.color,
          ),
          CustomButton.customTextButton(
            "Yes",
            onPressed: () {
              context.pop(["Yes"]);
            },
            buttonTextColor: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ],
      );
    },
  );
  if (res == null) {
    return false;
  } else {
    return res.contains("Yes");
  }
}

Future<bool> deleteAccountDialog(
  BuildContext context,
  String loggedInEmail,
) async {
  final GlobalKey<FormState> accountDeleteFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  List<String>? res = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Delete Account"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: UiConstant.spaceBetweenCard,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Type your email to confirm",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            Form(
              key: accountDeleteFormKey,
              child: CustomFormField.textFormField(
                emailController,
                hintText: 'Email',
                labelText: 'Your Email',
                validator: (value) {
                  String? error = CustomValidator.validateEmail(value);
                  if (error == null && loggedInEmail != emailController.text) {
                    return "Wrong Email";
                  } else {
                    return error;
                  }
                },
                inputDecoration: TextFormFieldInputBorder.underLine,
                borderColor:
                    Theme.of(
                      context,
                    ).inputDecorationTheme.enabledBorder!.borderSide.color,
              ),
            ),
          ],
        ),
        actions: [
          CustomButton.customTextButton(
            "Cancel",
            onPressed: () {
              context.pop(["No"]);
            },
            buttonTextColor: Theme.of(context).textTheme.bodyLarge!.color,
          ),
          CustomButton.customTextButton(
            "Confirm",
            onPressed: () {
              if (accountDeleteFormKey.currentState!.validate()) {
                context.pop(["Yes"]);
              }
            },
            buttonTextColor: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ],
      );
    },
  );
  if (res == null) {
    return false;
  } else {
    return res.contains("Yes");
  }
}

List<BoxShadow> getContainerBoxShadow(BuildContext context) {
  if (Theme.brightnessOf(context) == Brightness.light) {
    return [
      BoxShadow(
        color: Colors.black.withAlpha(1),
        spreadRadius: 1,
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ];
  } else {
    return [
      BoxShadow(
        color: Theme.of(context).colorScheme.shadow,
        spreadRadius: 2,
        blurRadius: 5,
        offset: Offset(0, 3),
      ),
    ];
  }
}
