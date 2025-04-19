import 'dart:math';

import 'package:flutter/material.dart';
import 'package:settlenow_v2/constant/home_ui_constant.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class PersonalExpenseTransactionScreen extends StatefulWidget {
  const PersonalExpenseTransactionScreen({super.key});

  @override
  State<PersonalExpenseTransactionScreen> createState() =>
      _PersonalExpenseTransactionScreenState();
}

class _PersonalExpenseTransactionScreenState
    extends State<PersonalExpenseTransactionScreen> {
  final List<String> tagsTitle = [];

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: 14,
        (context, index) => Card(
          elevation: UiConstant.cardElevation,
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(UiConstant.cardPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    tagOnCard(expenseCategories[0]),
                    ...List.generate(
                      tagsTitle.length,
                      (index) => tagOnCard(
                        tagsTitle[index],
                        textColor: UiConstant.colors[1],
                        backgroundColor: UiConstant.colorsWithShade50[1],
                      ),
                    ),
                  ],
                ),
                ListTile(
                  leading: colouredIcon(
                    Icon(categoryIcons[index % categoryIcons.length]),
                    UiConstant.colorsWithShade100[index % categoryIcons.length],
                  ),
                  title: Text("Chickoo Ice-Cream"),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      subTextOnCard("Created On March 10, 2025"),
                      index % 2 == 0
                          ? subTextOnCard("Modified On March 12, 2025")
                          : subTextOnCard(""),
                    ],
                  ),
                  trailing: Text(
                    formatCurrency(
                      (121 + Random().nextInt(300)) * 1.0,
                      context,
                    ),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
