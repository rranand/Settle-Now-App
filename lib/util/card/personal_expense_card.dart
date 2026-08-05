import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/internationalization/currency.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/router/router_constant.dart';
import 'package:settlenow/util/util_core.dart';

class PersonalExpenseCard extends StatelessWidget {
  final PersonalExpenseInfoModel data;
  const PersonalExpenseCard({super.key, required this.data});

  Widget textWidget(
    String text,
    BuildContext context, {
    bool isCurrency = false,
    bool isLoaded = true,
    double fontSize = 20,
  }) {
    return isLoaded
        ? Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: isCurrency ? Colors.green : null,
          ),
        )
        : CustomShimmerEffect.textWidget(
          context,
          fontSize: fontSize,
          width: isCurrency ? 60 : 100,
        );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
      onTap: () {
        if (data.hasData) {
          context.push(
            "${RouterConstants.personalExpenseRouteName}/${data.year}/${data.monthName}",
          );
        }
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
            boxShadow: getContainerBoxShadow(context),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textWidget(data.monthName, context, isLoaded: data.hasData),
              const SizedBox(height: UiConstant.cardSpaceBetweenSubText),
              textWidget(data.year, context, isLoaded: data.hasData),
              const SizedBox(height: 2 * UiConstant.cardSpaceBetweenSubText),
              textWidget(
                formatCurrency(data.amount, context),
                context,
                isCurrency: true,
                isLoaded: data.hasData,
                fontSize: 22,
              ),
              const SizedBox(height: 2 * UiConstant.cardSpaceBetweenSubText),
              tagOnCard(
                "${data.transactionCount} transaction${data.transactionCount > 1 ? "s" : ""}",
                context,
                textColor: UiConstant.colors[0],
                backgroundColor: UiConstant.colorsWithShade50[0],
                isLoaded: data.hasData,
              ),
              const SizedBox(height: UiConstant.cardSpaceAfterSubText),
            ],
          ),
        ),
      ),
    );
  }
}
