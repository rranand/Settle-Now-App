import 'package:flutter/material.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/util/widgets/category_parser.dart';

class TransactionWidget extends StatefulWidget {
  const TransactionWidget({super.key});

  @override
  State<TransactionWidget> createState() => _TransactionWidgetState();
}

class _TransactionWidgetState extends State<TransactionWidget> {
  Widget subTextWidget(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha(51)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                CategoryParser.getCategoryEmojiAsWidget("Food"),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Purchased a burger",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subTextWidget("Rohit Anand"),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatCurrency(100, context)),
              subTextWidget("March 10, 2025"),
            ],
          ),
        ],
      ),
    );
  }
}
