import 'package:flutter/material.dart';

class CustomButton {
  static Widget customElevatedButton(
    String buttonText, {
    double? buttonHeight,
    double elevation = 0,
    double? buttonWidth,
    double? buttonTextSize,
    double borderWidth = 1,
    double? borderRadius,
    Color? borderColor,
    Color? backgroundColor,
    Color? buttonTextColor,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: buttonWidth ?? double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: elevation,
          backgroundColor: backgroundColor ?? Colors.black,
          side: BorderSide(
            width: borderWidth,
            color: borderColor ?? Colors.black,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: buttonTextSize,
            color: buttonTextColor ?? Colors.white,
          ),
        ),
      ),
    );
  }

  static Widget customOutlinedButton(
    String buttonText, {
    double? buttonHeight,
    double? buttonWidth,
    double? buttonTextSize,
    Color buttonTextColor = Colors.black,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: buttonWidth ?? double.infinity,
      height: buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text(
          buttonText,
          style: TextStyle(fontSize: buttonTextSize, color: buttonTextColor),
        ),
      ),
    );
  }

  static Widget customTextButton(
    String buttonText, {
    double? buttonHeight,
    double elevation = 0,
    double? buttonWidth,
    double? buttonTextSize,
    double borderWidth = 1,
    double? borderRadius,
    Color? borderColor,
    Color? backgroundColor,
    Color? buttonTextColor,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: buttonWidth ?? double.infinity,
      height: buttonHeight,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.black,
          side: BorderSide(
            width: borderWidth,
            color: borderColor ?? Colors.black,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: buttonTextSize,
            color: buttonTextColor ?? Colors.white,
          ),
        ),
      ),
    );
  }

  static Widget socialButton(
    BuildContext context,
    String imagePath, {
    VoidCallback? onPressed,
    double? iconRadius,
    Color? iconBorderColor,
  }) {
    iconRadius ??= 20;
    iconBorderColor ??= Colors.black26;

    return InkWell(
      onTap: onPressed,
      child: CircleAvatar(
        radius: iconRadius + 2,
        backgroundColor: iconBorderColor,
        child: CircleAvatar(
          radius: iconRadius + 1,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Image.asset(
              imagePath,
              height: iconRadius,
              width: iconRadius,
            ),
          ),
        ),
      ),
    );
  }
}
