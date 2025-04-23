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
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: elevation,
          backgroundColor: backgroundColor,
          side: BorderSide(
            width: borderWidth,
            color: borderColor ?? Colors.transparent,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 100),
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
    double elevation = 0,
    Color? backgroundColor,
    double borderWidth = 1,
    Color? borderColor,
    double? borderRadius,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          elevation: elevation,
          backgroundColor: backgroundColor,
          side: BorderSide(
            width: borderWidth,
            color: borderColor ?? Colors.transparent,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 100),
          ),
        ),
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
      width: buttonWidth,
      height: buttonHeight,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.transparent,
          side: BorderSide(
            width: borderWidth,
            color: borderColor ?? Colors.transparent,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 100),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          buttonText,
          style: TextStyle(fontSize: buttonTextSize, color: buttonTextColor),
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
      borderRadius: BorderRadius.circular(iconRadius),
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

  static Widget customFloatingButton(IconData icon, VoidCallback? onPressed) {
    return FloatingActionButton(
      onPressed: onPressed,
      elevation: 1,
      backgroundColor: Colors.deepPurpleAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      child: Icon(icon, size: 24, color: Colors.white),
    );
  }
}
