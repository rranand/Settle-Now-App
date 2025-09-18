import 'package:flutter/material.dart';
import 'package:settlenow/internationalization/currency.dart';

class BarGroup extends StatelessWidget {
  final String user;
  final double contribution;
  final double spent;
  final double maxOverallValue;
  final Color? color;

  const BarGroup({
    super.key,
    required this.user,
    required this.contribution,
    required this.spent,
    required this.maxOverallValue,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double contributionPercentage = (contribution / maxOverallValue);
    final double spentPercentage = (spent / maxOverallValue);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              user,
              maxLines: 4,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BarLine(
                  value: contribution,
                  percentage: contributionPercentage,
                  color: color == null ? Color(0xFF3B82F6) : color!,
                ),
                Visibility(
                  visible: spent != -1,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: BarLine(
                      value: spent,
                      percentage: spentPercentage,
                      color: color == null ? Color(0xFFEF4444) : color!,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
