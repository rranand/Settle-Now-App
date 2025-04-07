import 'package:flutter/material.dart';

class GradientWidget extends StatelessWidget {
  final List<Color> gradientColors;
  final String text;
  final double textSize;
  final Color textColor;

  const GradientWidget({
    super.key,
    required this.gradientColors,
    required this.text,
    required this.textSize,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: textSize),
        ),
      ),
    );
  }
}
