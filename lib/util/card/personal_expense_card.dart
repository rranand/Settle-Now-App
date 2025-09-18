import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow/constant/ui_constant.dart';
import 'package:settlenow/internationalization/currency.dart';
import 'package:settlenow/model/personal_expense_info_model.dart';
import 'package:settlenow/router/router_constant.dart';
import 'package:settlenow/util/widgets/shimmer_effect.dart';
import 'package:settlenow/util/widgets/widgets.dart';

class PersonalExpenseCard extends StatelessWidget {
  final PersonalExpenseInfoModel data;
  const PersonalExpenseCard({super.key, required this.data});

  Widget textWidget(
    String text,
    BuildContext context, {
    bool isCurrency = false,
    bool isLoaded = true,
  }) {
    return isLoaded
        ? Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isCurrency ? Colors.green : null,
          ),
        )
        : CustomShimmerEffect.textWidget(
          context,
          fontSize: 18,
          width: isCurrency ? 60 : 100,
        );
  }

  Widget linerChartForPersonalExpenseDashBoard(BuildContext context) {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            maxContentWidth: 100,
            getTooltipColor: (touchedSpot) => Colors.black,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final textStyle = TextStyle(
                  color:
                      touchedSpot.bar.gradient?.colors[0] ??
                      touchedSpot.bar.color,
                  fontSize: 14,
                );
                return LineTooltipItem(
                  formatCurrency(touchedSpot.y, context),
                  textStyle,
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
          getTouchLineStart: (data, index) => 0,
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              data.transaction.length,
              (i) => FlSpot(i.toDouble(), data.transaction[i]),
            ),
            isCurved: true,
            color: Colors.green.shade50,
            gradient: const LinearGradient(
              colors: [Color(0xFF14b8a6), Color(0xFF0f766e)],
            ),
            dotData: FlDotData(show: true),
            barWidth: 2,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
      onTap: () {
        if (data.hasData) {
          context.push(
            "${RouterConstants.personalExpenseRouteName}/${data.year}/${data.monthName}",
          );
        }
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
            boxShadow: getContainerBoxShadow(context),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textWidget(data.monthName, context, isLoaded: data.hasData),
              const SizedBox(height: UiConstant.cardSpaceBetweenSubText),
              textWidget(
                formatCurrency(data.amount, context),
                context,
                isCurrency: true,
                isLoaded: data.hasData,
              ),
              const SizedBox(height: UiConstant.cardSpaceAfterSubText),
              Expanded(
                child:
                    data.hasData
                        ? Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(
                              UiConstant.cardBorderRadius,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: linerChartForPersonalExpenseDashBoard(
                              context,
                            ),
                          ),
                        )
                        : CustomShimmerEffect.placeHolderShimmerEffect(
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                UiConstant.cardBorderRadius,
                              ),
                            ),
                          ),
                          context,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
