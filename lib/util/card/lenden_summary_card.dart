import 'package:flutter/material.dart';
import 'package:settlenow_v2/constant/gradient_color_constant.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/model/lenden_room_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/util/custom/pair.dart';

class LendenSummaryCard extends StatelessWidget {
  final List<LendenRoomModel> data;
  final UserModel loggedInUser;

  const LendenSummaryCard({
    super.key,
    required this.data,
    required this.loggedInUser,
  });

  Pair<double, double> calculateBalance() {
    double gaveAmount = 0;
    double oweAmount = 0;

    for (int i = 0; i < data.length; i++) {
      bool isMe = data[i].createdBy.id == loggedInUser.id;

      if (isMe) {
        if (data[i].amount < 0) {
          oweAmount += data[i].amount.abs();
        } else {
          gaveAmount += data[i].amount;
        }
      } else {
        if (data[i].amount < 0) {
          gaveAmount += data[i].amount.abs();
        } else {
          oweAmount += data[i].amount;
        }
      }
    }
    return Pair(gaveAmount, oweAmount);
  }

  @override
  Widget build(BuildContext context) {
    Pair<double, double> balance = calculateBalance();
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
