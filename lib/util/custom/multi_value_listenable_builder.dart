import 'package:flutter/material.dart';

class MultiValueListenableBuilder extends StatelessWidget {
  final List<Listenable> listenables;
  final Widget Function(BuildContext) builder;

  const MultiValueListenableBuilder({
    required this.listenables,
    required this.builder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(listenables),
      builder: (context, _) => builder(context),
    );
  }
}
