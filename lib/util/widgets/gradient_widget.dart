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
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor, fontSize: textSize),
        ),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  final List<Color> gradientColors;
  final String text;
  final double textSize;
  final double? letterSpacing;

  const GradientText({
    super.key,
    required this.gradientColors,
    required this.text,
    required this.textSize,
    this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback:
          (bounds) => LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
      child: Text(
        text,
        style: TextStyle(
          fontSize: textSize,
          fontWeight: FontWeight.bold,
          letterSpacing: letterSpacing,
          color: Colors.white,
        ),
      ),
    );
  }
}

class GradientBorderCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final List<Color> gradientColors;
  final Color? backgroundColor;

  const GradientBorderCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.borderWidth = 2,
    this.gradientColors = const [Color(0xFF4F46E5), Color(0xFF3B82F6)],
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: EdgeInsets.all(borderWidth),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(borderRadius - 2),
        ),
        child: child,
      ),
    );
  }
}
