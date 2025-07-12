import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = (color.r * 255.0).round() & 0xff,
        g = (color.g * 255.0).round() & 0xff,
        b = (color.b * 255.0).round() & 0xff;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.toARGB32(), swatch);
  }

  // 1. Blue
  static MaterialColor blue = _createMaterialColor(
    const Color(0xFF2196F3),
  ); // Material Blue 500

  // 2. Teal
  static MaterialColor teal = _createMaterialColor(
    const Color(0xFF009688),
  ); // Material Teal 500

  // 3. Green
  static MaterialColor green = _createMaterialColor(
    const Color(0xFF4CAF50),
  ); // Material Green 500

  // 4. Lime
  static MaterialColor lime = _createMaterialColor(
    const Color(0xFFCDDC39),
  ); // Material Lime 500

  // 5. Yellow
  static MaterialColor yellow = _createMaterialColor(
    const Color(0xFFFFEB3B),
  ); // Material Yellow 500

  // 6. Orange
  static MaterialColor orange = _createMaterialColor(
    const Color(0xFFFF9800),
  ); // Material Orange 500

  // 7. Deep Orange
  static MaterialColor deepOrange = _createMaterialColor(
    const Color(0xFFFF5722),
  ); // Material Deep Orange 500

  // 8. Red
  static MaterialColor red = _createMaterialColor(
    const Color(0xFFF44336),
  ); // Material Red 500

  // 9. Pink
  static MaterialColor pink = _createMaterialColor(
    const Color(0xFFE91E63),
  ); // Material Pink 500

  // 10. Purple
  static MaterialColor purple = _createMaterialColor(
    const Color(0xFF9C27B0),
  ); // Material Purple 500

  // 11. Indigo
  static MaterialColor indigo = _createMaterialColor(
    const Color(0xFF3F51B5),
  ); // Material Indigo 500

  // 12. Cyan
  static MaterialColor cyan = _createMaterialColor(
    const Color(0xFF00BCD4),
  ); // Material Cyan 500

  // 13. Brown
  static MaterialColor brown = _createMaterialColor(
    const Color(0xFF795548),
  ); // Material Brown 500

  // 14. Blue Grey
  static MaterialColor blueGrey = _createMaterialColor(
    const Color(0xFF607D8B),
  ); // Material Blue Grey 500

  // 15. Amber
  static MaterialColor amber = _createMaterialColor(
    const Color(0xFFFFC107),
  ); // Material Amber 500

  static final List<MaterialColor> categoryColors = [
    orange,
    deepOrange,
    red,
    pink,
    purple,
    indigo,
    blue,
    teal,
    green,
    lime,
    yellow,
    cyan,
    brown,
    blueGrey,
    amber,
  ];

  static MaterialColor getColorByIndex(int index) {
    return categoryColors[index % categoryColors.length];
  }
}
