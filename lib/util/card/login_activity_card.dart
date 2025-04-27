import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/widgets/button_with_shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

enum DeviceType { mobile, web }

extension DeviceTypeExtension on DeviceType {
  Color get color {
    switch (this) {
      case DeviceType.mobile:
        return Colors.blue.shade100;
      case DeviceType.web:
        return Colors.green.shade100;
    }
  }

  IconData get icon {
    switch (this) {
      case DeviceType.mobile:
        return Iconsax.mobile;
      case DeviceType.web:
        return Iconsax.monitor;
    }
  }

  static DeviceType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'mobile':
        return DeviceType.mobile;
      case 'web':
        return DeviceType.web;
      default:
        throw Exception("Unknown device type: $value");
    }
  }
}

class LoginActivityCard extends StatelessWidget {
  final String deviceType;
  const LoginActivityCard({super.key, required this.deviceType});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: UiConstant.cardElevation,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: colouredIcon(
            Icon(DeviceTypeExtension.fromString(deviceType).icon),
            DeviceTypeExtension.fromString(deviceType).color,
          ),
          title: Text("Pixel 7 Pro"),
          subtitle: Text.rich(
            TextSpan(
              text: deviceType,
              style: TextStyle(fontSize: 12, color: Colors.grey),
              children: [
                TextSpan(text: "\nActive "),
                TextSpan(
                  text: convertToMoment(
                    DateTime.now().add(Duration(hours: -10)),
                  ),
                ),
              ],
            ),
          ),
          trailing: ButtonWithShimmerEffect(
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
