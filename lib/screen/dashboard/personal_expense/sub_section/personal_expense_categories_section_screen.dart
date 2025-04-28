import 'dart:math';

import 'package:flutter/material.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

import '../../../../core.dart';

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
    return SliverList.builder(
      itemCount: CategoryParser.expenseCategories.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          elevation: UiConstant.cardElevation,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(UiConstant.cardPadding),
            child: ListTile(
              leading: colouredIcon(
                Icon(CategoryParser.expenseCategoryIcons[index]),
                UiConstant.colorsWithShade100[index],
              ),
              title: Text(CategoryParser.expenseCategories[index]),
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
      },
    );
  }
}
