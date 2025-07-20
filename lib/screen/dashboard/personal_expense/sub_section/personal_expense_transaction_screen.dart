import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/bloc/personal_expense/monthly_expense/personal_expense_bloc.dart';
import 'package:settlenow_v2/constant/calender_constant.dart';
import 'package:settlenow_v2/model/personal_expense_transaction_model.dart';
import 'package:settlenow_v2/util/card/transaction_card.dart';
import 'package:settlenow_v2/util/handler/filter_sort.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class PersonalExpenseTransactionScreen extends StatefulWidget {
  final TextEditingController searchController;
  const PersonalExpenseTransactionScreen({
    super.key,
    required this.searchController,
  });

  @override
  State<PersonalExpenseTransactionScreen> createState() =>
      _PersonalExpenseTransactionScreenState();
}

class _PersonalExpenseTransactionScreenState
    extends State<PersonalExpenseTransactionScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      PersonalMonthlyExpenseBloc,
      PersonalMonthlyExpenseState
    >(
      listener: (context, state) {},
      builder: (context, state) {
        bool isEditable = false;
        List<PersonalExpenseTransactionModel> data = List.filled(
          10,
          PersonalExpenseTransactionModel.empty(),
        );
        if (state is PersonalMonthlyExpenseFetchSuccess) {
          data = state.data;
          DateTime currentDate = DateTime.now();
          int year = int.parse(state.id.substring(0, 4));
          String month = state.id.substring(4);
          if (currentDate.year == year &&
              CalenderConstant.getIndexOfMonth(month) + 1 ==
                  currentDate.month) {
            isEditable = true;
          }
        }
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: widget.searchController,
          builder: (context, _, _) {
            List<PersonalExpenseTransactionModel> filterData = data;
            if (state is PersonalMonthlyExpenseFetchSuccess) {
              filterData = FilterSort.filteredSearchText(
                widget.searchController.text,
                data,
                (transData) =>
                    "${transData.description} ${transData.amount} ${transData.category} ${transData.roomData.roomName}",
              );
            }

            if (filterData.isEmpty) {
              return SliverToBoxAdapter(
                child: noRecordFoundWidget("No Matching Records", context),
              );
            }

            return SliverList.builder(
              itemCount: filterData.length,
              itemBuilder:
                  (context, index) => TransactionCard(
                    data: filterData[index],
                    isEditable: isEditable,
                  ),
            );
          },
        );
      },
    );
  }
}
