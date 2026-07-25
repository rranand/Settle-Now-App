import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/internationalization/currency.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class PersonalExpenseCategoriesSectionScreen extends StatefulWidget {
  const PersonalExpenseCategoriesSectionScreen({super.key});

  @override
  State<PersonalExpenseCategoriesSectionScreen> createState() =>
      _PersonalExpenseCategoriesSectionScreenState();
}

class _PersonalExpenseCategoriesSectionScreenState
    extends State<PersonalExpenseCategoriesSectionScreen> {
  Widget categoryCardDisplay(
    bool isLoaded,
    List<Pair<double, int>> categoryWiseExpense,
  ) {
    return SliverList.builder(
      itemCount: CategoryParser.expenseCategories.length,
      itemBuilder: (BuildContext context, int index) {
        if (isLoaded && categoryWiseExpense[index].second == 0) {
          return SizedBox.shrink();
        }
        return Card(
          child: Container(
            padding: const EdgeInsets.all(UiConstant.cardPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
              boxShadow: getContainerBoxShadow(context),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  isLoaded
                      ? colouredIcon(
                        CategoryParser.expenseCategoryIcons[index],
                        UiConstant.colorsWithShade100[index],
                      )
                      : CustomShimmerEffect.imageWidget(
                        context,
                        shape: BoxShape.circle,
                        radius: 50,
                      ),
              title:
                  isLoaded
                      ? Text(CategoryParser.expenseCategories[index])
                      : CustomShimmerEffect.textWidget(context, width: 80),
              subtitle:
                  isLoaded
                      ? Text(
                        "${categoryWiseExpense[index].second} transactions",
                      )
                      : CustomShimmerEffect.textWidget(
                        context,
                        fontSize: 10,
                        width: 80,
                      ),
              trailing:
                  isLoaded
                      ? Text(
                        formatCurrency(
                          categoryWiseExpense[index].first,
                          context,
                        ),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                      : CustomShimmerEffect.textWidget(
                        context,
                        fontSize: 15,
                        width: 80,
                      ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PersonalMonthlyExpenseBloc, PersonalMonthlyExpenseState>(
      builder: (context, state) {
        List<Pair<double, int>> categoryWiseExpense = List.generate(
          CategoryParser.getCategoryList().length,
          (i) => Pair<double, int>(0, 0),
        );

        if (state is PersonalMonthlyExpenseFetchSuccess) {
          if (state.data.isEmpty) {
            return SliverToBoxAdapter(
              child: noRecordFoundWidget("No Transaction Found", context),
            );
          }
          return BlocBuilder<FilterCubit, FilterState>(
            builder: (context, filterState) {
              categoryWiseExpense = List.generate(
                CategoryParser.getCategoryList().length,
                (i) => Pair<double, int>(0, 0),
              );
              for (int i = 0; i < filterState.data.length; i++) {
                PersonalExpenseTransactionModel eachExpense =
                    filterState.data[i];
                int index = CategoryParser.indexOfCategory(
                  eachExpense.category,
                );

                categoryWiseExpense[index].first += eachExpense.amount;
                categoryWiseExpense[index].second += 1;
              }
              if (filterState.data.isEmpty) {
                return SliverToBoxAdapter(
                  child: noRecordFoundWidget(
                    ApiConstant.noMatchingRecords,
                    context,
                  ),
                );
              }
              return categoryCardDisplay(true, categoryWiseExpense);
            },
          );
        } else {
          return categoryCardDisplay(false, categoryWiseExpense);
        }
      },
    );
  }
}
