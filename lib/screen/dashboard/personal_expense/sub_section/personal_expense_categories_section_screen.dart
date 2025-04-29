import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/bloc/personal_expense/monthly_expense/personal_expense_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
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
    return BlocBuilder<PersonalMonthlyExpenseBloc, PersonalMonthlyExpenseState>(
      builder: (context, state) {
        bool isLoaded = state is PersonalMonthlyExpenseFetchSuccess;

        return SliverList.builder(
          itemCount: CategoryParser.expenseCategories.length,
          itemBuilder: (BuildContext context, int index) {
            if (isLoaded && state.data.first[index].second == 0) {
              return SizedBox.shrink();
            }
            return Card(
              elevation: UiConstant.cardElevation,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(UiConstant.cardPadding),
                child: ListTile(
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
                            "${state.data.first[index].second} transactions",
                          )
                          : CustomShimmerEffect.textWidget(
                            fontSize: 10,
                            width: 80,
                          ),
                  trailing:
                      isLoaded
                          ? Text(
                            formatCurrency(
                              state.data.first[index].first,
                              context,
                            ),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                          : CustomShimmerEffect.textWidget(
                            fontSize: 15,
                            width: 80,
                          ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
