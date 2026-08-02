import 'package:flutter/material.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/internationalization/currency.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class LendenSummaryCard extends StatelessWidget {
  final LendenDashboardModel data;
  final UserModel loggedInUser;

  const LendenSummaryCard({
    super.key,
    required this.data,
    required this.loggedInUser,
  });

  @override
  Widget build(BuildContext context) {
    Pair<double, double> balance = data.getAmount();
    final netBalance = balance.first - balance.second;

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSection("You Gave", balance.first, Colors.green[700]!, context),
          _divider(),
          _buildSection("You Owe", balance.second, Colors.red[600]!, context),
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
