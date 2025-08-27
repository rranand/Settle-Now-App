import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/bloc/room/each_room/room_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/cubit/room/room_user/room_user_cubit.dart';
import 'package:settlenow_v2/model/category_amount_model.dart';
import 'package:settlenow_v2/model/room_user_model.dart';
import 'package:settlenow_v2/model/transaction_model.dart';
import 'package:settlenow_v2/model/user_financial_model.dart';
import 'package:settlenow_v2/util/graph/expense_by_user_data_screen.dart';
import 'package:settlenow_v2/util/graph/expense_by_category_data_screen.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class RoomAnalysisScreen extends StatefulWidget {
  const RoomAnalysisScreen({super.key});

  @override
  State<RoomAnalysisScreen> createState() => _RoomAnalysisScreenState();
}

class _RoomAnalysisScreenState extends State<RoomAnalysisScreen> {
  final List<String> graphTitle = ["Expense By Category", "Expense By User"];
  final ValueNotifier _selectedGraphIndex = ValueNotifier(0);
  int _categoryHashCode = 0;
  int _roomUserHashCode = 0;
  List<CategoryAmountModel> categoryAmountModel = [];
  List<UserFinancialData> userFinancialData = [];

  Widget expenseByCategoryGraph(List<TransactionModel> data) {
    if (_categoryHashCode != data.hashCode) {
      _categoryHashCode = data.hashCode;
      final Map<String, double> categoryData = {};
      for (final transaction in data) {
        categoryData[transaction.category] =
            (categoryData[transaction.category] ?? 0) + transaction.amount;
      }
      categoryAmountModel =
          categoryData.entries
              .map(
                (entry) => CategoryAmountModel(
                  category: entry.key,
                  amount: entry.value,
                ),
              )
              .toList();
      _categoryHashCode = categoryAmountModel.hashCode;
    }

    return ExpenseByCategoryDataScreen(
      categoryAmountModel: categoryAmountModel,
    );
  }

  Widget expenseByUserGraph() {
    if (_roomUserHashCode != userFinancialData.hashCode) {
      final state = context.read<RoomUserCubit>().state;
      List<RoomUserModel> data = [];
      if (state is RoomUserSuccess) {
        data = state.data;
      }
      userFinancialData =
          data
              .map((user) => UserFinancialData.fromRoomUserModel(user))
              .toList();
      _roomUserHashCode = userFinancialData.hashCode;
    }

    return ExpenseByUserDataScreen(userFinancialData: userFinancialData);
  }

  Widget _graphController(int index, List<TransactionModel> data) {
    switch (index) {
      case 0:
        return expenseByCategoryGraph(data);
      case 1:
        return expenseByUserGraph();
      default:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomBloc, RoomState>(
      builder: (context, state) {
        if (state is RoomFetchSuccess) {
          List<TransactionModel> data = state.data;

          if (data.isEmpty) {
            return SliverToBoxAdapter(
              child: noRecordFoundWidget("No Transaction Found", context),
            );
          } else {
            return ValueListenableBuilder(
              valueListenable: _selectedGraphIndex,
              builder: (context, _, _) {
                return SliverList(
                  delegate: SliverChildListDelegate([
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: UiConstant.spaceBetweenCard,
                        children: List.generate(
                          graphTitle.length,
                          (index) => InkWell(
                            borderRadius: BorderRadius.circular(60),
                            onTap: () => _selectedGraphIndex.value = index,
                            child: Chip(
                              label: Text(
                                graphTitle[index],
                                style: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color,
                                ),
                              ),
                              side: BorderSide(
                                color:
                                    index == _selectedGraphIndex.value
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context)
                                            .textSelectionTheme
                                            .cursorColor!
                                            .withAlpha(50),
                              ),
                              labelStyle:
                                  index == _selectedGraphIndex.value
                                      ? TextStyle()
                                      : null,
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: UiConstant.spaceBetweenSection),
                    _graphController(_selectedGraphIndex.value, data),
                  ]),
                );
              },
            );
          }
        } else {
          return SliverToBoxAdapter(
            child: Center(child: RefreshProgressIndicator()),
          );
        }
      },
    );
  }
}
