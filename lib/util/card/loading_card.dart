import 'package:flutter/material.dart';
import 'package:settlenow/util/util_core.dart';

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
    double height = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: height * .5 - _imageSize * 1.2),
        SizedBox(
          width: MediaQuery.of(context).size.width,
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
        Expanded(child: SizedBox()),
      ],
    );
  }
}
