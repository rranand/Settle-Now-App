import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/bloc/personal_expense/monthly_expense/personal_expense_bloc.dart';
import 'package:settlenow_v2/model/personal_expense_transaction_model.dart';
import 'package:settlenow_v2/util/card/transaction_card.dart';

class PersonalExpenseTransactionScreen extends StatefulWidget {
  const PersonalExpenseTransactionScreen({super.key});

  @override
  State<PersonalExpenseTransactionScreen> createState() =>
      _PersonalExpenseTransactionScreenState();
}

class _PersonalExpenseTransactionScreenState
    extends State<PersonalExpenseTransactionScreen> {
  final List<String> tagsTitle = [];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      PersonalMonthlyExpenseBloc,
      PersonalMonthlyExpenseState
    >(
      listener: (context, state) {},
      builder: (context, state) {
        List<PersonalExpenseTransactionModel> data = List.filled(
          10,
          PersonalExpenseTransactionModel.empty(),
        );
        if (state is PersonalMonthlyExpenseFetchSuccess) {
          data = state.data;
        }
        return SliverList.builder(
          itemCount: data.length,
          itemBuilder: (context, index) => TransactionCard(data: data[index]),
        );
      },
    );
  }
}
