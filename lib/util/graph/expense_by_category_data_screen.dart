import 'package:flutter/material.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class ExpenseByCategoryDataScreen extends StatefulWidget {
  final List<CategoryAmountModel> categoryAmountModel;
  const ExpenseByCategoryDataScreen({
    super.key,
    required this.categoryAmountModel,
  });

  @override
  State<ExpenseByCategoryDataScreen> createState() =>
      _ExpenseByCategoryDataScreenState();
}

class _ExpenseByCategoryDataScreenState
    extends State<ExpenseByCategoryDataScreen> {
  double maxOverallValue = 0;

  @override
  void initState() {
    super.initState();
    _calculateMaxOverallValue();
  }

  void _calculateMaxOverallValue() {
    for (CategoryAmountModel data in widget.categoryAmountModel) {
      if (data.amount > maxOverallValue) {
        maxOverallValue = data.amount;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children:
              widget.categoryAmountModel.map((data) {
                MaterialColor color = AppColors.getColorByIndex(
                  CategoryParser.indexOfCategory(data.category),
                );

                return BarGroup(
                  user: data.category,
                  contribution: data.amount,
                  spent: -1,
                  maxOverallValue: maxOverallValue,
                  color: color,
                );
              }).toList(),
        ),
        Container(
          padding: const EdgeInsets.only(top: 16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
          ),
          child: Wrap(
            spacing: UiConstant.spaceBetweenCard,
            runSpacing: UiConstant.spaceBetweenCard,
            children:
                widget.categoryAmountModel.map((data) {
                  MaterialColor color = AppColors.getColorByIndex(
                    CategoryParser.indexOfCategory(data.category),
                  );
                  return LegendItem(color: color, text: data.category);
                }).toList(),
          ),
        ),
      ],
    );
  }
}
