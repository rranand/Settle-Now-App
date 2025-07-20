import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/bloc/personal_expense/monthly_expense/personal_expense_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/cubit/filter/filter_cubit.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

import '../../../../core.dart';

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
          elevation: UiConstant.cardElevation,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(UiConstant.cardPadding),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  isLoaded
                      ? colouredIcon(
                        Icon(CategoryParser.expenseCategoryIcons[index]),
                        UiConstant.colorsWithShade100[index],
                      )
                      : CustomShimmerEffect.imageWidget(
                        shape: BoxShape.circle,
                        radius: 50,
                      ),
              title:
                  isLoaded
                      ? Text(CategoryParser.expenseCategories[index])
                      : CustomShimmerEffect.textWidget(width: 80),
              subtitle:
                  isLoaded
                      ? Text(
                        "${categoryWiseExpense[index].second} transactions",
                      )
                      : CustomShimmerEffect.textWidget(fontSize: 10, width: 80),
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
                      : CustomShimmerEffect.textWidget(fontSize: 15, width: 80),
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
