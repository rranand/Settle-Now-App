import 'dart:math';

import 'package:flutter/material.dart';

class CustomShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double boxSize;

  const CustomShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    required this.boxSize,
  });

  @override
  State<CustomShimmer> createState() => _CustomShimmerState();
}

class _CustomShimmerState extends State<CustomShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<double> getDiagonalShimmerStops(double progress) {
    final totalDiagonal = sqrt(2 * widget.boxSize * widget.boxSize);
    final center = progress * totalDiagonal;

    final halfBand = 150 / 2;
    final leading = (center - halfBand).clamp(0.0, totalDiagonal);
    final trailing = (center + halfBand).clamp(0.0, totalDiagonal);

    return [
      leading / totalDiagonal,
      center / totalDiagonal,
      trailing / totalDiagonal,
    ];
  }

  @override
  Widget build(BuildContext context) {
    Color base = Theme.of(context).colorScheme.surfaceTint;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            final double progress = _controller.value;
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                base.withAlpha(50),
                base.withAlpha(255),
                base.withAlpha(50),
              ],
              stops: getDiagonalShimmerStops(progress),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
