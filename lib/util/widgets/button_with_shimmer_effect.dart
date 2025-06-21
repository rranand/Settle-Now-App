import 'package:flutter/material.dart';
import 'package:settlenow_v2/util/enum/enums.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';

class ButtonWithShimmerEffect extends StatelessWidget {
  final bool isLoaded;
  final String buttonText;
  final CustomButtonType buttonType;
  final double? elevation;
  final double? buttonHeight;
  final double? buttonWidth;
  final double? buttonTextSize;
  final double? borderWidth;
  final double? borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? buttonTextColor;
  final VoidCallback? onPressed;

  const ButtonWithShimmerEffect({
    super.key,
    required this.isLoaded,
    required this.buttonText,
    required this.buttonType,
    this.buttonHeight,
    this.buttonWidth,
    this.buttonTextSize,
    this.borderWidth,
    this.borderRadius,
    this.borderColor,
    this.backgroundColor,
    this.buttonTextColor,
    this.elevation,
    this.onPressed,
  });

  Widget getCustomButton() {
    switch (buttonType) {
      case CustomButtonType.customElevatedButton:
        {
          return CustomButton.customElevatedButton(
            buttonText,
            elevation: elevation ?? 0,
            buttonWidth: buttonWidth,
            buttonHeight: buttonHeight,
            borderColor: borderColor,
            backgroundColor: backgroundColor,
            onPressed: onPressed,
            buttonTextColor: buttonTextColor,
            buttonTextSize: buttonTextSize,
            borderRadius: borderRadius,
          );
        }
      case CustomButtonType.customOutlinedButton:
        {
          return CustomButton.customOutlinedButton(
            buttonText,
            buttonWidth: buttonWidth,
            buttonHeight: buttonHeight,
            onPressed: onPressed,
            buttonTextColor: buttonTextColor ?? Colors.black,
            buttonTextSize: buttonTextSize,
            elevation: elevation ?? 0,
            borderColor: borderColor,
            backgroundColor: backgroundColor,
            borderRadius: borderRadius,
          );
        }
      case CustomButtonType.customTextButton:
        {
          return CustomButton.customTextButton(
            buttonText,
            elevation: elevation ?? 0,
            buttonWidth: buttonWidth,
            buttonHeight: buttonHeight,
            borderColor: borderColor,
            backgroundColor: backgroundColor,
            onPressed: onPressed,
            buttonTextColor: buttonTextColor,
            buttonTextSize: buttonTextSize,
            borderRadius: borderRadius,
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoaded
        ? SizedBox(
          width: buttonWidth ?? double.infinity,
          height: buttonHeight,
          child: CustomShimmerEffect.loadingShimmerEffect(
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: borderColor ?? Colors.transparent,
                  width: borderWidth ?? 1,
                ),
                borderRadius: BorderRadius.circular(borderRadius ?? 100),
              ),
            ),
          ),
        )
        : getCustomButton();
  }
}
