import 'package:flutter/material.dart';
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
    return SliverList.builder(
      itemCount: 14,
      itemBuilder:
          (context, index) =>
              TransactionCard(index: index, tagsTitle: tagsTitle),
    );
  }
}
