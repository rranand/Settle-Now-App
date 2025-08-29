import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:settlenow_v2/constant/calender_constant.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/cubit/new_transaction/new_transaction_cubit.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/model/personal_expense_transaction_model.dart';
import 'package:settlenow_v2/model/transaction_model.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/custom/category_parser.dart';
import 'package:settlenow_v2/util/enum/transaction_type.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class TransactionCard extends StatefulWidget {
  final PersonalExpenseTransactionModel data;
  final bool isEditable;

  const TransactionCard({
    super.key,
    required this.data,
    required this.isEditable,
  });

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  bool showEdited() {
    return !isDateTimeSame(widget.data.createdOn, widget.data.modifiedOn) ||
        !widget.data.hasData;
  }

  List<String> createTags() {
    if (!widget.data.hasData) {
      return List.filled(1, "");
    }
    List<String> tags = [widget.data.category];
    if (!isDateTimeSame(widget.data.createdOn, widget.data.modifiedOn)) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(
                    tags.length,
                    (index) => tagOnCard(
                      tags[index],
                      textColor: UiConstant.colors[index],
                      backgroundColor: UiConstant.colorsWithShade50[index],
                      isLoaded: widget.data.hasData,
                    ),
                  ),
                ),
                widget.data.hasData && widget.isEditable
                    ? InkWell(
                      borderRadius: BorderRadius.circular(
                        UiConstant.cardBorderRadius,
                      ),
                      child: Icon(
                        widget.data.roomData.hasData
                            ? Icons.delete_outline
                            : Iconsax.edit_copy,
                        color: Colors.grey,
                        size: widget.data.roomData.hasData ? null : 20,
                      ),
                      onTap: () async {
                        if (widget.data.roomData.hasData) {
                          final NewTransactionCubit newTransactionCubit =
                              context.read<NewTransactionCubit>();
                          bool isDeleteAllowed = await deleteExpenseDialog(
                            context,
                          );
                          if (context.mounted && isDeleteAllowed) {
                            newTransactionCubit.deleteExpense(
                              context,
                              widget.data.id,
                              TransactionType.personal,
                              expenseType: widget.data.roomData.transactionType,
                            );
                          }
                        } else {
                          context.push(
                            "${RouterConstants.personalExpenseRouteName}/${widget.data.createdOn.year}/${CalenderConstant.monthName[widget.data.createdOn.month]}${RouterConstants.personalExpenseEditExpenseRouteName}",
                            extra: TransactionModel.fromPersonalExpense(
                              widget.data,
                            ),
                          );
                        }
                      },
                    )
                    : SizedBox.shrink(),
              ],
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  widget.data.hasData
                      ? colouredIcon(
                        CategoryParser.expenseCategoryIcons[categoryIndex %
                            CategoryParser.expenseCategoryIcons.length],
                        UiConstant.colorsWithShade100[categoryIndex %
                            CategoryParser.expenseCategoryIcons.length],
                      )
                      : CustomShimmerEffect.imageWidget(
                        shape: BoxShape.circle,
                        radius: 50,
                      ),
              title:
                  widget.data.hasData
                      ? Text(widget.data.description)
                      : CustomShimmerEffect.textWidget(width: 100),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  subTextOnCard(
                    "Created On ${convertDateTimeFormat(widget.data.createdOn)}",
                    isLoaded: widget.data.hasData,
                  ),
                  showEdited()
                      ? subTextOnCard(
                        "Updated On ${convertDateTimeFormat(widget.data.modifiedOn)}",
                        isLoaded: widget.data.hasData,
                      )
                      : subTextOnCard(""),
                ],
              ),
              trailing:
                  widget.data.hasData
                      ? Text(
                        formatCurrency(widget.data.amount, context),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                      : CustomShimmerEffect.textWidget(fontSize: 20, width: 40),
            ),
          ],
        ),
      ),
    );
  }
}
