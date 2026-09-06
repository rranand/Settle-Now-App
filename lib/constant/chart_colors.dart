import 'package:flutter/material.dart';

class ChartColors {
  ChartColors._();

  // Fixed order — assign by sorted index, never by category id/hash.
  static const List<Color> categoryPalette = [
    Color(0xFF378ADD), // blue
    Color(0xFFD85A30), // coral
    Color(0xFF1D9E75), // teal
    Color(0xFFBA7517), // amber
    Color(0xFF7F77DD), // purple
    Color(0xFFD4537E), // pink
    Color(0xFF639922), // green
    Color(0xFF99653C), // brown
  ];

  static const Color otherCategoryColor = Color(0xFF5F5E5A);
  static const Color contributionColor = Color(0xFF378ADD);
  static const Color spentColor = Color(0xFFD85A30);
}
