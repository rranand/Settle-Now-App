import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/model/login_activity_model.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/widgets/button_with_shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

enum DeviceType { mobile, web, other }

extension DeviceTypeExtension on DeviceType {
  Color get color {
    switch (this) {
      case DeviceType.mobile:
        return Colors.blue.shade100;
      case DeviceType.web:
        return Colors.green.shade100;
      default:
        return Colors.redAccent.shade100;
    }
  }

  IconData get icon {
    switch (this) {
      case DeviceType.mobile:
        return Iconsax.mobile;
      case DeviceType.web:
        return Iconsax.monitor;
      default:
        return Icons.devices_other_outlined;
    }
  }

  static DeviceType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'mobile':
        return DeviceType.mobile;
      case 'web':
        return DeviceType.web;
      default:
        return DeviceType.other;
    }
  }
}

class LoginActivityCard extends StatelessWidget {
  final LoginActivityModel data;
  const LoginActivityCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (!data.hasData) {
      return CustomShimmerEffect.placeHolderShimmerEffect(
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
    return Card(
      elevation: UiConstant.cardElevation,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: colouredIcon(
            Icon(DeviceTypeExtension.fromString(data.deviceType).icon),
            DeviceTypeExtension.fromString(data.deviceType).color,
          ),
          title: Text(data.deviceName),
          subtitle: Text.rich(
            TextSpan(
              text: data.deviceType,
              style: TextStyle(fontSize: 12, color: Colors.grey),
              children: [
                TextSpan(text: "\nActive "),
                TextSpan(text: convertToMoment(data.lastLoggedIn)),
              ],
            ),
          ),
          trailing:
              data.id.isEmpty
                  ? ButtonWithShimmerEffect(
                    buttonText: "Current",
                    buttonType: CustomButtonType.customElevatedButton,
                    isLoaded: false,
                    buttonHeight: 40,
                    buttonWidth: 100,
                    backgroundColor: Colors.green.shade400,
                    onPressed: () {},
                  )
                  : ButtonWithShimmerEffect(
                    buttonText: "Log Out",
                    buttonType: CustomButtonType.customElevatedButton,
                    isLoaded: false,
                    buttonHeight: 40,
                    buttonWidth: 100,
                    backgroundColor: Colors.red.shade400,
                    onPressed: () {},
                  ),
        ),
      ),
    );
  }
}
