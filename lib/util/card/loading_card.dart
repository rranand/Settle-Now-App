import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});
  final double _imageSize = 150;

  Widget imageData() {
    return Image.asset(
      'assets/sn/SN_WBG.png',
      width: _imageSize,
      height: _imageSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: height * .5 - _imageSize * 1.2),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.surfaceTint.withAlpha(50),
            highlightColor: Theme.of(context).colorScheme.surfaceTint,
            direction: ShimmerDirection.ttb,
            period: Duration(seconds: 2),
            child: imageData(),
          ),
        ),
        Expanded(child: SizedBox()),
      ],
    );
  }
}
