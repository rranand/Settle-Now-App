import 'package:flutter/material.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/util/graph/horizontal_graph_card.dart';

class RoomAnalysisScreen extends StatefulWidget {
  const RoomAnalysisScreen({super.key});

  @override
  State<RoomAnalysisScreen> createState() => _RoomAnalysisScreenState();
}

class _RoomAnalysisScreenState extends State<RoomAnalysisScreen> {
  final List<String> graphTitle = ["Expense By Category", "Expense By User"];
  final ValueNotifier _selectedGraphIndex = ValueNotifier(0);

  final Map<String, double> categoryData = {
    'Food & Dining': 2200.0,
    'Housing': 0.0,
    'Transportation': 150.0,
    'Utilities': 75.5,
    'Entertainment': 90.0,
    'Health & Fitness': 45.0,
    'Shopping': 130.0,
    'Education': 80.0,
    'Travel': 200.0,
    'Miscellaneous': 60.0,
  };

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ValueListenableBuilder(
        valueListenable: _selectedGraphIndex,
        builder: (context, value, _) {
          return Column(
            children: [
              Wrap(
                spacing: UiConstant.spaceBetweenCard,
                runSpacing: UiConstant.spaceBetweenCard,
                children: List.generate(
                  graphTitle.length,
                  (index) => Chip(
                    label: Text(graphTitle[index]),
                    labelStyle:
                        index == value ? TextStyle(color: Colors.white) : null,
                    backgroundColor:
                        index == value
                            ? Colors.deepPurple.shade500
                            : Colors.white,
                  ),
                ),
              ),
              SizedBox(height: UiConstant.spaceBetweenSection),
              HorizontalGraphCard(data: categoryData),
            ],
          );
        },
      ),
    );
  }
}
