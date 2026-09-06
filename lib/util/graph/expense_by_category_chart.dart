import 'package:flutter/material.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/internationalization/currency.dart';
import 'package:settlenow/model/model_core.dart';

class ExpenseByCategoryChart extends StatelessWidget {
  final List<CategoryAmountModel> data;
  final int maxVisibleCategories;

  const ExpenseByCategoryChart({
    super.key,
    required this.data,
    this.maxVisibleCategories = 8,
  });

  List<CategoryAmountModel> _prepareData() {
    final sorted = [...data]..sort((a, b) => b.amount.compareTo(a.amount));

    if (sorted.length <= maxVisibleCategories) return sorted;

    final visible = sorted.take(maxVisibleCategories - 1).toList();
    final otherTotal = sorted
        .skip(maxVisibleCategories - 1)
        .fold<double>(0, (sum, e) => sum + e.amount);

    visible.add(CategoryAmountModel(category: 'Other', amount: otherTotal));
    return visible;
  }

  Color _colorFor(int index, String name) {
    if (name == 'Other') return ChartColors.otherCategoryColor;
    return ChartColors.categoryPalette[index %
        ChartColors.categoryPalette.length];
  }

  @override
  Widget build(BuildContext context) {
    final prepared = _prepareData();
    if (prepared.isEmpty) return const SizedBox.shrink();

    final maxAmount = prepared
        .map((e) => e.amount)
        .reduce((a, b) => a > b ? a : b);

    final totalAmount = prepared.fold<double>(0, (sum, e) => sum + e.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < prepared.length; i++) ...[
          _CategoryBarRow(
            data: prepared[i],
            maxAmount: maxAmount,
            totalAmount: totalAmount,
            color: _colorFor(i, prepared[i].category),
          ),
          if (i != prepared.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _CategoryBarRow extends StatelessWidget {
  final CategoryAmountModel data;
  final double maxAmount;
  final double totalAmount;
  final Color color;
  final double barHeight = 25.0;

  const _CategoryBarRow({
    required this.data,
    required this.maxAmount,
    required this.totalAmount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final widthFactor =
        maxAmount == 0 ? 0.0 : (data.amount / maxAmount).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(data.category, style: TextStyle(fontSize: 14)),
            Text(
              "${formatCurrency(data.amount.floorToDouble(), context)} · ${(data.amount / totalAmount * 100).toStringAsFixed(1)}%",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: barHeight,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(barHeight * 0.9),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: widthFactor),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  builder:
                      (context, value, _) => Container(
                        height: barHeight,
                        width: constraints.maxWidth * value,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(barHeight * 0.9),
                        ),
                      ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
