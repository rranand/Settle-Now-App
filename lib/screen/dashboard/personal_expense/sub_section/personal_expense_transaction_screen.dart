import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/bloc/personal_expense/monthly_expense/personal_expense_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/util/card/transaction_card.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';

class PersonalExpenseTransactionScreen extends StatefulWidget {
  const PersonalExpenseTransactionScreen({super.key});

  @override
  State<PersonalExpenseTransactionScreen> createState() =>
      _PersonalExpenseTransactionScreenState();
}

class _PersonalExpenseTransactionScreenState
    extends State<PersonalExpenseTransactionScreen> {
  final List<String> tagsTitle = [];

  Widget shimmerWidget() {
    return SliverList.builder(
      itemCount: 14,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          elevation: UiConstant.cardElevation,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(UiConstant.cardPadding),
            child: ListTile(
              leading: CustomShimmerEffect.imageWidget(
                shape: BoxShape.circle,
                radius: 50,
              ),
              title: CustomShimmerEffect.textWidget(width: 80),
              subtitle: CustomShimmerEffect.textWidget(fontSize: 10, width: 80),
              trailing: CustomShimmerEffect.textWidget(fontSize: 15, width: 80),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      PersonalMonthlyExpenseBloc,
      PersonalMonthlyExpenseState
    >(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is! PersonalMonthlyExpenseFetchSuccess) {
          return shimmerWidget();
        } else {
          return SliverList.builder(
            itemCount: state.data.second.length,
            itemBuilder:
                (context, index) =>
                    TransactionCard(data: state.data.second[index]),
          );
        }
      },
    );
  }
}
