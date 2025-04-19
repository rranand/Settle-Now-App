import 'dart:math';

import 'package:flutter/material.dart';
import 'package:settlenow_v2/constant/home_ui_constant.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

// TODO : Sort By Option

class PersonalExpenseCategoriesSectionScreen extends StatefulWidget {
  const PersonalExpenseCategoriesSectionScreen({super.key});

  @override
  State<PersonalExpenseCategoriesSectionScreen> createState() =>
      _PersonalExpenseCategoriesSectionScreenState();
}

class _PersonalExpenseCategoriesSectionScreenState
    extends State<PersonalExpenseCategoriesSectionScreen> {
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: expenseCategories.length,
        (context, index) => ListTile(
          leading: colouredIcon(
            Icon(categoryIcons[index]),
            UiConstant.colorsWithShade100[index],
          ),
          title: Text(expenseCategories[index]),
          subtitle: Text("${index + Random().nextInt(4) + 2} transactions"),
          trailing: Text(
            formatCurrency(
              ((index + 1) * 300 + Random().nextInt(300)) * 1.0,
              context,
            ),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
