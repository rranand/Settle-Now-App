import 'package:flutter/material.dart';
import 'package:settlenow/constant/ui_constant.dart';
import 'package:settlenow/internationalization/currency.dart';
import 'package:settlenow/model/bulk_transaction_model.dart';
import 'package:settlenow/util/custom/category_parser.dart';
import 'package:settlenow/util/widgets/widgets.dart';

class BulkTransactionCard extends StatefulWidget {
  final ValueNotifier<List<BulkTransactionModel>> data;
  final int index;
  const BulkTransactionCard({
    super.key,
    required this.data,
    required this.index,
  });

  @override
  State<BulkTransactionCard> createState() => _BulkTransactionCardState();
}

class _BulkTransactionCardState extends State<BulkTransactionCard> {
  final ValueNotifier<int> _selectedCategory = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    int categoryIndex = CategoryParser.indexOfCategory(
      widget.data.value[widget.index].category,
    );

    return Card(
      child: Container(
        padding: EdgeInsets.all(UiConstant.cardPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
          boxShadow: getContainerBoxShadow(context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: colouredIcon(
                CategoryParser.expenseCategoryIcons[categoryIndex %
                    CategoryParser.expenseCategoryIcons.length],
                UiConstant.colorsWithShade100[categoryIndex %
                    CategoryParser.expenseCategoryIcons.length],
              ),
              title: Text(
                widget.data.value[widget.index].description,
                style: TextStyle(fontSize: UiConstant.cardTitleTextSize),
              ),
              subtitle: Text(
                formatCurrency(widget.data.value[widget.index].amount, context),
                style: TextStyle(
                  fontSize: UiConstant.cardTitleTextSize - 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: ValueListenableBuilder(
                valueListenable: _selectedCategory,
                builder: (context, _, _) {
                  return DropdownButton<String>(
                    underline: SizedBox.shrink(),
                    value:
                        CategoryParser.expenseCategories[_selectedCategory
                            .value],
                    items: List.generate(
                      CategoryParser.expenseCategories.length,
                      (index) => DropdownMenuItem(
                        value: CategoryParser.expenseCategories[index],
                        child: Text(CategoryParser.expenseCategories[index]),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        _selectedCategory.value = CategoryParser
                            .expenseCategories
                            .indexOf(value);
                        widget.data.value[widget.index] = widget
                            .data
                            .value[widget.index]
                            .copyWith(category: value);
                        widget.data.value = [...widget.data.value];
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
