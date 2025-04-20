import 'package:flutter/material.dart';
import 'package:settlenow_v2/constant/gradient_color_constant.dart';
import 'package:settlenow_v2/internationalization/currency.dart';

class LendenSummaryCard extends StatelessWidget {
  final double gaveAmount;
  final double oweAmount;

  const LendenSummaryCard({
    super.key,
    required this.gaveAmount,
    required this.oweAmount,
  });

  @override
  Widget build(BuildContext context) {
    final netBalance = gaveAmount - oweAmount;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: GradientColorConstant.mintBreeze,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSection("You Gave", gaveAmount, Colors.green[700]!, context),
          _divider(),
          _buildSection("You Owe", oweAmount, Colors.red[600]!, context),
          _divider(),
          _buildSection(
            "Net Balance",
            netBalance.abs(),
            Colors.blueGrey[800]!,
            context,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 40,
    color: Colors.grey[300],
    margin: const EdgeInsets.symmetric(horizontal: 12),
  );

  Widget _buildSection(
    String title,
    double amount,
    Color color,
    BuildContext context,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        Text(
          formatCurrency(amount, context),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
