import 'package:flutter/material.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/internationalization/currency.dart';
import 'package:settlenow/model/model_core.dart';

class ExpenseByUserChart extends StatelessWidget {
  final List<RoomUserModel> data;

  const ExpenseByUserChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxValue = data
        .expand((u) => [u.contribution, u.spent])
        .fold<double>(0, (max, v) => v > max ? v : max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _UserChartLegend(),
        const SizedBox(height: 16),
        for (int i = 0; i < data.length; i++) ...[
          _UserBarRow(user: data[i], maxValue: maxValue),
          if (i != data.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _UserChartLegend extends StatelessWidget {
  const _UserChartLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _dot(ChartColors.contributionColor),
        const SizedBox(width: 6),
        Text('Contribution', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 16),
        _dot(ChartColors.spentColor),
        const SizedBox(width: 6),
        Text('Spent', style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _dot(Color color) => Container(
    width: 9,
    height: 9,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

class _UserBarRow extends StatelessWidget {
  final RoomUserModel user;
  final double maxValue;
  final double textFontSize = 14.0;
  final double barHeight = 25.0;

  const _UserBarRow({required this.user, required this.maxValue});

  double _factor(double value) =>
      maxValue == 0 ? 0.0 : (value / maxValue).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final labelColor = Theme.of(context).textTheme.bodyMedium?.color;

    return SizedBox(
      height: 20,
      child: Row(
        children: [
          // Contribution — grows toward the center from the left
          Expanded(
            child:
                user.contribution > 0
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 54,
                          child: Text(
                            formatCurrency(
                              user.contribution.floorToDouble(),
                              context,
                            ),
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: textFontSize,
                              fontWeight: FontWeight.w600,
                              color: labelColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FractionallySizedBox(
                              widthFactor: _factor(user.contribution),
                              child: Container(
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color: ChartColors.contributionColor,
                                  borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(barHeight * 0.9),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                    : const SizedBox.shrink(),
          ),
          // Center name label
          SizedBox(
            width: 100,
            child: Text(
              user.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: textFontSize,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
          ),
          // Spent — grows toward the center from the right
          Expanded(
            child:
                user.spent > 0
                    ? Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: _factor(user.spent),
                              child: Container(
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color: ChartColors.spentColor,
                                  borderRadius: BorderRadius.horizontal(
                                    right: Radius.circular(barHeight * 0.9),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 54,
                          child: Text(
                            formatCurrency(user.spent.floorToDouble(), context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: textFontSize,
                              fontWeight: FontWeight.w600,
                              color: labelColor,
                            ),
                          ),
                        ),
                      ],
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
