import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/personal_expense/monthly_expense/personal_expense_bloc.dart';
import 'package:settlenow/constant/calender_constant.dart';
import 'package:settlenow/cubit/filter/filter_cubit.dart';
import 'package:settlenow/model/personal_expense_transaction_model.dart';
import 'package:settlenow/util/card/transaction_card.dart';
import 'package:settlenow/util/handler/filter_sort.dart';
import 'package:settlenow/util/widgets/widgets.dart';

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
  Widget transactionCardDisplay(
    List<PersonalExpenseTransactionModel> data,
    bool isEditable,
  ) {
    return SliverList.builder(
      itemCount: data.length,
      itemBuilder:
          (context, index) =>
              TransactionCard(data: data[index], isEditable: isEditable),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PersonalMonthlyExpenseBloc, PersonalMonthlyExpenseState>(
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

          if (data.isEmpty) {
            return SliverToBoxAdapter(
              child: noRecordFoundWidget("No Transaction Found", context),
            );
          }

          return BlocBuilder<FilterCubit, FilterState>(
            builder: (context, filterState) {
              return ValueListenableBuilder<TextEditingValue>(
                valueListenable: widget.searchController,
                builder: (context, _, _) {
                  List<PersonalExpenseTransactionModel> searchedData =
                      filterState.data.cast<PersonalExpenseTransactionModel>();

                  searchedData = FilterSort.filteredSearchText(
                    widget.searchController.text,
                    searchedData,
                    (transData) =>
                        "${transData.description} ${transData.amount} ${transData.category} ${transData.roomData.roomName}",
                  );

                  if (searchedData.isEmpty) {
                    return SliverToBoxAdapter(
                      child: noRecordFoundWidget(
                        "No Matching Records",
                        context,
                      ),
                    );
                  }

                  return transactionCardDisplay(searchedData, isEditable);
                },
              );
            },
          );
        } else {
          return transactionCardDisplay(data, isEditable);
        }
      },
    );
  }
}
