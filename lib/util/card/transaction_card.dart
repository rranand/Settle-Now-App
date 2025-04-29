import 'package:flutter/material.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/model/personal_expense_transaction_model.dart';
import 'package:settlenow_v2/util/custom/category_parser.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class TransactionCard extends StatefulWidget {
  final PersonalExpenseTransactionModel data;

  const TransactionCard({super.key, required this.data});

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  List<String> createTags() {
    List<String> tags = [widget.data.category];
    if (widget.data.createdOn != widget.data.modifiedOn) {
      tags.add("Edited");
    }
    if (widget.data.roomData.hasData) {
      tags.add(widget.data.roomData.roomName);
    }
    return tags;
  }

  @override
  Widget build(BuildContext context) {
    int categoryIndex = CategoryParser.indexOfCategory(widget.data.category);
    List<String> tags = createTags();

    return Card(
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
              children: List.generate(
                tags.length,
                (index) => tagOnCard(
                  tags[index],
                  textColor: UiConstant.colors[index],
                  backgroundColor: UiConstant.colorsWithShade50[index],
                ),
              ),
            ),
            ListTile(
              leading: colouredIcon(
                Icon(
                  CategoryParser.expenseCategoryIcons[categoryIndex %
                      CategoryParser.expenseCategoryIcons.length],
                ),
                UiConstant.colorsWithShade100[categoryIndex %
                    CategoryParser.expenseCategoryIcons.length],
              ),
              title: Text(widget.data.description),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  subTextOnCard(
                    "Created On ${convertDateTimeFormat(widget.data.modifiedOn)}",
                  ),
                  widget.data.modifiedOn != widget.data.createdOn
                      ? subTextOnCard(
                        "Modified On ${convertDateTimeFormat(widget.data.modifiedOn)}",
                      )
                      : subTextOnCard(""),
                ],
              ),
              trailing: Text(
                formatCurrency(widget.data.amount, context),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
