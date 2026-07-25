import 'package:flutter/material.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/internationalization/currency.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

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
  final ValueNotifier<bool> isExpanded = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    int categoryIndex = CategoryParser.indexOfCategory(
      widget.data.value[widget.index].category,
    );

    return Stack(
      children: [
        Card(
          child: Container(
            padding: EdgeInsets.all(UiConstant.cardPadding + 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
              boxShadow: getContainerBoxShadow(context),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                colouredIcon(
                  CategoryParser.expenseCategoryIcons[categoryIndex %
                      CategoryParser.expenseCategoryIcons.length],
                  UiConstant.colorsWithShade100[categoryIndex %
                      CategoryParser.expenseCategoryIcons.length],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data.value[widget.index].description,
                          style: TextStyle(
                            fontSize: UiConstant.cardTitleTextSize,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: UiConstant.cardSpaceBetweenSubText,
                          ),
                          child: Text(
                            formatCurrency(
                              widget.data.value[widget.index].amount,
                              context,
                            ),
                            style: TextStyle(
                              fontSize: UiConstant.cardTitleTextSize - 1,
                            ),
                          ),
                        ),
                        ValueListenableBuilder(
                          valueListenable: isExpanded,
                          builder: (context, _, _) {
                            if (!isExpanded.value) {
                              return SizedBox.shrink();
                            }
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Category",
                                  style: TextStyle(
                                    fontSize: UiConstant.cardTitleTextSize,
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodyLarge!.color,
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: ValueListenableBuilder(
                                      valueListenable: _selectedCategory,
                                      builder: (context, _, _) {
                                        return DropdownButton<String>(
                                          underline: SizedBox.shrink(),
                                          value:
                                              CategoryParser
                                                  .expenseCategories[_selectedCategory
                                                  .value],
                                          items: List.generate(
                                            CategoryParser
                                                .expenseCategories
                                                .length,
                                            (index) => DropdownMenuItem(
                                              value:
                                                  CategoryParser
                                                      .expenseCategories[index],
                                              child: Text(
                                                CategoryParser
                                                    .expenseCategories[index],
                                              ),
                                            ),
                                          ),
                                          onChanged: (value) {
                                            if (value != null) {
                                              _selectedCategory
                                                  .value = CategoryParser
                                                  .expenseCategories
                                                  .indexOf(value);
                                              widget.data.value[widget
                                                  .index] = widget
                                                  .data
                                                  .value[widget.index]
                                                  .copyWith(category: value);
                                              widget.data.value = [
                                                ...widget.data.value,
                                              ];
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: InkWell(
            borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
            child: ValueListenableBuilder(
              valueListenable: isExpanded,
              builder: (context, _, _) {
                return Icon(
                  isExpanded.value
                      ? Icons.keyboard_arrow_up_outlined
                      : Icons.keyboard_arrow_down_outlined,
                  size: 28,
                  color: Colors.grey,
                );
              },
            ),
            onTap: () {
              isExpanded.value = !isExpanded.value;
            },
          ),
        ),
      ],
    );
  }
}
