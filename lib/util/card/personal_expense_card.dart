import 'package:flutter/material.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';

class PersonalExpenseCard extends StatelessWidget {
  final int index;
  const PersonalExpenseCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: UiConstant.colors[index % UiConstant.colors.length],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withAlpha(51)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: [Text("December 2025")]),
    );
  }
}
