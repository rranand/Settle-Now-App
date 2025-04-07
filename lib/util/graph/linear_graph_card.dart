import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:settlenow_v2/internationalization/currency.dart';

class LinearGraphCard extends StatelessWidget {
  final List<double> expenses;
  final String monthName;
  const LinearGraphCard({
    super.key,
    required this.expenses,
    required this.monthName,
  });

  @override
  Widget build(BuildContext context) {
    double totalAmount = expenses.reduce((value, element) => value + element);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.green.shade200,
      ),
      child: Column(
        children: [
          Text.rich(
            TextSpan(
              text: formatCurrency(totalAmount.toInt().toDouble(), context),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              children: [
                TextSpan(
                  text: (totalAmount - totalAmount.toInt().toDouble())
                      .toStringAsFixed(2)
                      .substring(1),
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          Text(
            monthName,
            style: TextStyle(fontSize: 16, color: Colors.white60),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      getTitlesWidget: (value, _) {
                        int day = value.toInt() + 1;
                        if (day % 5 == 0 || day == 1) {
                          return Text(
                            day.toString().padLeft(2, '0'),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      expenses.length,
                      (index) => FlSpot(index.toDouble(), expenses[index]),
                    ),
                    isCurved: true,
                    color: Colors.white,
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
