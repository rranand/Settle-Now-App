import 'package:flutter/material.dart';

class CustomGestureDetector extends StatefulWidget {
  final Widget child;
  final ValueNotifier<int> navBarIndex;
  final int totalTitle;

  const CustomGestureDetector({
    super.key,
    required this.child,
    required this.navBarIndex,
    required this.totalTitle,
  });

  @override
  State<CustomGestureDetector> createState() => _CustomGestureDetectorState();
}

class _CustomGestureDetectorState extends State<CustomGestureDetector>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double dragThreshold = 0.3;

    final double draggedFromCurrentPageStart =
        details.localPosition.dx - (-widget.navBarIndex.value * screenWidth);

    int targetPageIndex = widget.navBarIndex.value;

    if (details.primaryVelocity! < -500.0 ||
        draggedFromCurrentPageStart < -screenWidth * dragThreshold) {
      targetPageIndex++;
    } else if (details.primaryVelocity! > 500.0 ||
        draggedFromCurrentPageStart > screenWidth * dragThreshold) {
      targetPageIndex--;
    }

    targetPageIndex = targetPageIndex.clamp(0, widget.totalTitle - 1);

    widget.navBarIndex.value = targetPageIndex;

    animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: widget.child,
    );
  }
}
