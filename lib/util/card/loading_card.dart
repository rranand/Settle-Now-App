import 'package:flutter/material.dart';
import 'package:settlenow/util/widgets/custom_shimmer.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
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
    return Scaffold(
      body: Center(
        child: CustomShimmer(
          duration: const Duration(seconds: 3),
          boxSize: _imageSize,
          child: Image.asset(
            'assets/sn/SN_WBG.png',
            width: _imageSize,
            height: _imageSize,
            color: Colors.white,
            colorBlendMode: BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
