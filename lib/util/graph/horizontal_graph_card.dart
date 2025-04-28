import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/util/custom/category_parser.dart';

class HorizontalGraphCard extends StatelessWidget {
  final Map<String, double> data;
  const HorizontalGraphCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final categories = data.keys.toList();
    final values = data.values.toList();

    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 40),
        child: AspectRatio(
          aspectRatio: 0.9,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceBetween,
              rotationQuarterTurns: 1,
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.black54, width: 0.3),
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                leftTitles: const AxisTitles(
                  drawBelowEverything: true,
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      return SideTitleWidget(
                        meta: meta,
                        child: Icon(
                          CategoryParser.getCategoryIconByCategory(
                            categories[index],
                          ),
                          color: UiConstant.colors[index],
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine:
                    (value) =>
                        FlLine(color: Colors.grey.shade300, strokeWidth: 1),
              ),
              barGroups: List.generate(values.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: values[index],
                      width: 8,
                      borderRadius: BorderRadius.circular(4),
                      color: UiConstant.colors[index],
                    ),
                  ],
                );
              }),
              barTouchData: BarTouchData(
                enabled: true,
                handleBuiltInTouches: false,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => Colors.transparent,
                  tooltipMargin: 0,
                  getTooltipItem: (
                    BarChartGroupData group,
                    int groupIndex,
                    BarChartRodData rod,
                    int rodIndex,
                  ) {
                    return BarTooltipItem(
                      rod.toY.toString(),
                      TextStyle(
                        fontWeight: FontWeight.bold,
                        color: rod.color,
                        fontSize: 18,
                        shadows: const [
                          Shadow(color: Colors.black26, blurRadius: 12),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
