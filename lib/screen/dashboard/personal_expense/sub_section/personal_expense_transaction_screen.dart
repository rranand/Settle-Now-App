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
  final double _cardPadding = 2;
  final double _containerPadding = 10;
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
            padding: EdgeInsets.all(_containerPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width:
                      MediaQuery.of(context).size.width -
                      2 * _cardPadding -
                      2 * _containerPadding,
                  height: 25,
                  child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: tagsTitle.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        return tagOnCard(
                          expenseCategories[index % expenseCategories.length],
                        );
                      } else {
                        return tagOnCard(
                          tagsTitle[index - 1],
                          textColor: UiConstant.colors[1],
                          backgroundColor: UiConstant.colorsWithShade50[1],
                        );
                      }
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(width: 8);
                    },
                  ),
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
