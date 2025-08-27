import 'package:flutter/material.dart';
import 'package:settlenow_v2/constant/gradient_color_constant.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.build_rounded,
                color: Theme.of(context).primaryColor,
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                'We\'ll be right back!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Our app is currently under scheduled maintenance.\nWe\'re working hard to improve your experience.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CustomShimmerEffect.loadingShimmerEffect(
                CircularProgressIndicator(),
                baseColor: GradientColorConstant.vibrantGradient.first,
                highlightColor: GradientColorConstant.vibrantGradient.last,
              ),
              const SizedBox(height: 16),
              Text(
                'Please check back soon!',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: Colors.black45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
