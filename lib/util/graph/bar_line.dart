import 'package:flutter/material.dart';
import 'package:settlenow/internationalization/currency.dart';

class BarLine extends StatelessWidget {
  final double value;
  final double percentage;
  final Color color;

  const BarLine({
    super.key,
    required this.value,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double barWidth = constraints.maxWidth * percentage;
        const double minTextDisplayWidth = 60.0;

        return Row(
          children: [
            Container(
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6.0),
              ),
              alignment: Alignment.centerRight,
              width: barWidth.isFinite ? barWidth : 0,
              child:
                  barWidth > minTextDisplayWidth
                      ? Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          formatCurrency(value, context).split(".")[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      )
                      : SizedBox.shrink(),
            ),
            Visibility(
              visible: barWidth <= minTextDisplayWidth,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  formatCurrency(value, context).split(".")[0],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
