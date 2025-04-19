import 'package:flutter/material.dart';

class PersonalExpenseTransactionScreen extends StatefulWidget {
  const PersonalExpenseTransactionScreen({super.key});

  @override
  State<PersonalExpenseTransactionScreen> createState() =>
      _PersonalExpenseTransactionScreenState();
}

class _PersonalExpenseTransactionScreenState
    extends State<PersonalExpenseTransactionScreen> {
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(height: 100, color: Colors.yellow, width: 100),
        ),
      ),
    );
  }
}
