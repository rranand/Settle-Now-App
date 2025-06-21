import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
      case 'web' || 'web browser':
        return DeviceType.web;
      default:
        return DeviceType.other;
    }
  }
}
