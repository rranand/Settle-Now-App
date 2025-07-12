import 'package:flutter/material.dart';
import 'package:settlenow_v2/model/user_financial_model.dart';
import 'package:settlenow_v2/util/graph/bar_group.dart';
import 'package:settlenow_v2/util/graph/legend_item.dart';

class ExpenseByUserDataScreen extends StatefulWidget {
  final List<UserFinancialData> userFinancialData;
  const ExpenseByUserDataScreen({super.key, required this.userFinancialData});

  @override
  State<ExpenseByUserDataScreen> createState() =>
      _ExpenseByUserDataScreenState();
}

class _ExpenseByUserDataScreenState extends State<ExpenseByUserDataScreen> {
  double maxOverallValue = 0;

  @override
  void initState() {
    super.initState();
    _calculateMaxOverallValue();
  }

  void _calculateMaxOverallValue() {
    for (UserFinancialData data in widget.userFinancialData) {
      if (data.contribution > maxOverallValue) {
        maxOverallValue = data.contribution;
      }
      if (data.spent > maxOverallValue) {
        maxOverallValue = data.spent;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children:
              widget.userFinancialData.map((data) {
                return BarGroup(
                  user: data.user.name,
                  contribution: data.contribution,
                  spent: data.spent,
                  maxOverallValue: maxOverallValue,
                );
              }).toList(),
        ),
        Container(
          padding: const EdgeInsets.only(top: 16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LegendItem(
                color: Color(0xFF3B82F6), // Blue 500
                text: 'Contribution',
              ),
              SizedBox(width: 24),
              LegendItem(
                color: Color(0xFFEF4444), // Red 500
                text: 'Spent',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
